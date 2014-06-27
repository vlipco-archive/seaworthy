function task.waypoint.deploy.run -a repo_fullname
	_announce "Deploying $repo_fullname"
	consul.ensure_leader_exists

	cd "$GIT_HOME/$repo_fullname"

	set -gx role (echo "$repo_fullname" | awk -F'/' '{print $1}')
	set -gx repository (echo "$repo_fullname" | awk -F'/' '{print $2}')
	set -gx revision (git log -n 1 --pretty=format:"%h")
	set -gx app_folder "$HOME/slugs/$repo_fullname"
	set -gx revision_folder "$app_folder/$revision"

	# cns stand for consul namespace
	set -gx app_cns "apps/$role/$repository"
	set -gx revisions_cns "$app_cns/revisions"
	set -gx latest_revision_key "$revisions_cns/latest"
	set -gx previous_revision_key "$revisions_cns/previous"

	# TODO fail is the role isn't covered in the cluster

	mkdir -p "$revision_folder"
	git archive $revision | tar xf - -C "$revision_folder"

	cd $revision_folder

	### _build_image
	### _save_app_data
	_handle_containers

end

function _build_image
	set builder (cat Seafile | grep builder | awk '{print $2}')

	_announce "Getting last version of builder image"

	_tcp_docker pull "$builder" 1> /dev/null

	set image_name "$role/$repository"
	_announce "Building $image_name with $builder"

	sti build . "$builder" "$image_name" -U "tcp://localhost:2375" 2>&1 | _indent_output

	set registry_image_name "localhost:5000/$image_name:$revision"
	_tcp_docker tag "$image_name" "$registry_image_name"

	_announce "Pushing resulting image to the cluster's registry, be patient..."

	_tcp_docker push "$registry_image_name" > /dev/null | _indent_output
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

	log.debug "Checking number of desired_instances"

	set desired_instances (consul.kv.get "$app_cns/instances")

	if [ -z "$desired_instances" ]
		log.debug "Setting desired_instances to 1"
		set desired_instances 1
		consul.kv.set "$app_cns/instances" $desired_instances
	end
	
	# containers ns
	set ctr_cns "containers/$role/$repository.$revision"
	log.debug "Iterating over instances"
	for i in (seq $desired_instances)
		consul.kv.set "$ctr_cns.$i/state" "init"
	end

	set running 0
	set wait_cycles 0


	log.debug "Checking instances state"
	# indent output with the rest
	echo -n "     "
	#   	echo [ "$running" != "$desired_instances" -o "$wait_cycles" != "30" ]
	while test "$running" -ne "$desired_instances" -a $wait_cycles -lt 30
	   	# sleep at the beginning, allows instances to boot
	   	sleep 1
	   	#log.debug "Increasing cycle counter -> "(math $wait_cycles + 1)
		set wait_cycles (math $wait_cycles + 1)
		set running (_running_instances_in $ctr_cns)
		echo -n "."
	end

	# break the line for correct format
	echo

	if [ "$running" != "$desired_instances" ]
		echo "     ERROR: Some units didn't boot properly, manual intervention required"
		exit 1
	else
		_announce "$desired_instances instances of $repository are now running"
	end
end

function _running_instances_in -a cns
	#log.debug "Finding running instances of $cns"
	set -l running 0
	for ctr in (consul.kv.ls $cns | grep state)
		set ctr_state (consul.kv.get $ctr)
		if [ "$ctr_state" = "running" ]
			set running (math $running + 1)
		else
		end
	end
	echo $running
end