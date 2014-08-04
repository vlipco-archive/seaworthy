function task.waypoint.deploy.run -a repo_fullname deploy_revision
	consul.ensure_leader_exists
	module.require docker

	cd "$GIT_HOME/bare/$repo_fullname"

	set -gx role (echo "$repo_fullname" | awk -F'/' '{print $1}')
	set -gx repository (echo "$repo_fullname" | awk -F'/' '{print $2}')

	if test "$deploy_revision"
		set -gx revision (echo $deploy_revision | cut -c 1-7 )
	else
		set -gx revision (git log -n 1 --pretty=format:"%h")
	end

	set -gx deploy_name "$role/$repository.$revision"
	set -gx app_folder "$HOME/slugs/$repo_fullname"
	set -gx revision_folder "$app_folder/$revision"

	_announce "Deploying $deploy_name"

	set rns (docker.registry_prefix)
	_announce "Using $rns as registry namespace"

	_announce "Login into the registry"
	docker.login

	# cns stand for consul namespace
	set -gx app_cns "apps/$role/$repository"
	set -gx revisions_cns "$app_cns/revisions"
	set -gx latest_revision_key "$revisions_cns/latest"
	set -gx previous_revision_key "$revisions_cns/previous"

	# TODO fail is the role isn't covered in the cluster

	mkdir -p "$revision_folder"
	git archive $revision | tar xf - -C "$revision_folder"

	cd $revision_folder

	if not cat Seafile | jq '.' >- ^&1
		echo "ERROR: Seafile is not valid JSON"
		exit 1
	end

	_announce "Saving Seafile to key-value storage"
	# store keyfile removing whitespace between key & value
	set flattened_seafile (cat Seafile | jq -M -c)
	consul.kv.set "$app_cns/seafile" "$flattened_seafile"

	_build_image
	_save_app_data
	_handle_containers

end


function _build_image
	set builder (consul.kv.get "$app_cns/seafile" | base64 --decode | filter_value "builder")

	_announce "Getting last version of $builder"

	docker.tcp pull "$builder" 1> /dev/null

	set prefix (docker.registry_prefix)
	set image_name "$prefix/$repository"
	set registry_image_name "$image_name:$revision"

	_announce "Building $deploy_name with $builder"

	sti build . "$builder" "$image_name" -U "tcp://localhost:2375" 2>&1; or exit 1

	docker.tcp tag "$image_name:latest" "$registry_image_name"

	_announce "Pushing resulting image to the cluster's registry, be patient..."
	
	# TODO error handling, e.g the registry is down  > /dev/null
	if docker.tcp push "$registry_image_name"
		echo "Push completed"
	else
		echo "ERROR: Push failed"
		exit 1
	end
end

function _save_app_data
	_announce "Saving information to distributed KV storage"

	consul.kv.set $previous_revision_key (consul.kv.get $latest_revision_key)
	consul.kv.set $latest_revision_key $revision

	set revision_data (printf '{"receiver":"%s","role":"%s", "date":"%s"}' \
	    (hostname) (iso_date) "$role")

	consul.kv.set "$revisions_cns/$revision" "$revision_data"

end

function _handle_containers
	_announce "Waiting for instances to start"

	set desired_instances (consul.kv.get "$app_cns/instances")

	if [ -z "$desired_instances" ]
		set desired_instances 1
		consul.kv.set "$app_cns/instances" $desired_instances
	end
	
	# containers ns
	set ctr_cns "containers/$deploy_name"
	
	log.info "Defining container instances to be run"
	for i in (seq $desired_instances)
		consul.kv.set "$ctr_cns.$i/state" "init"
	end


	_distribute $deploy_name

	set running 0
	set wait_cycles 0

	#   	echo [ "$running" != "$desired_instances" -o "$wait_cycles" != "30" ]
	while test "$running" -ne "$desired_instances" -a $wait_cycles -lt 30
	   	# sleep at the beginning, allows instances to boot
	   	sleep 1
		set wait_cycles (math $wait_cycles + 1)
		set running (consul.api.raw_get "catalog/service/$repository?tag=$revision" | jq -r '. | length')
		echo -n "."
	end

	# break the line for correct format
	echo

	if [ "$running" != "$desired_instances" ]
		echo "ERROR: Some units didn't boot properly, manual intervention required"
		exit 1
	else
		_announce "$desired_instances instances of $repository are now running"
	end

	# todo verify that new images exists for at least N seconds
	# perform healthcheck on new images?

	_announce "Stopping old instances of the image"
	for old in (consul.kv.ls "containers/$role/$repository" | grep -v "$revision")
		consul.kv.del "$old"
	end

	set total_running 0
	set wait_cycles 0

	echo -n "     "

	while test "$total_running" -ne "$desired_instances" -a $wait_cycles -lt 30
	   	sleep 1
		set wait_cycles (math $wait_cycles + 1)
		# we get count of ALL instances of the app
		set total_running (consul.api.raw_get "catalog/service/$repository" | jq -r '. | length')
		echo -n "."
	end
	echo 

	if [ "$total_running" != "$desired_instances" ]
		echo "     ERROR: Some old units didn't stop properly, manual intervention required"
		exit 1
	else
		_announce "Only recent container of the app are now running"
	end

	exit 0

end
