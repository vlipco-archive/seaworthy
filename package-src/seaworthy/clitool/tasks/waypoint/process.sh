function btask.waypoint.process.run {
	b.module.require consul
	
	# requires past this point will fail!
	cd $(b.get bang.working_dir)

	_netlog `pwd`
	while read oldrev newrev refname; do
      # Only run this script for the master branch. You can remove this 
      # if block if you wish to run it for others as well.
      if [[ $refname = "refs/heads/master" ]] ; then
 
        git archive $newrev | _process "$RECEIVE_REPO" "$newrev"
 
        rc=$?
        if [[ $rc != 0 ]] ; then
          echo "      ERROR: failed on rev $newrev - push denied"
          exit $rc
        fi
      fi
    done
}

function _announce { 
  msg="---> $1"
  echo -e "\e[1;33m${msg}\e[0m"
}

function _indent_output { 
  sed -u 's/^/     /'
}

function _tcp_docker {
	docker -H "tcp://localhost:2375" $@
}

function _process {
	
	consul.ensure_leader_exists

	# variables definition

	role="$(echo "$1" | awk -F'/' '{print $1}')"
	repository="$(echo "$1" | awk -F'/' '{print $2}')"
	# revision uses only 7 chars
	revision="${2:0:7}"
	app_folder="$HOME/slugs/$role/$repository"
	revision_folder="$app_folder/$revision"

	# TODO fail is the role isn't covered in the cluster

	_announce "Saving revision source"

	mkdir -p "$revision_folder"
	cd "$revision_folder"

	cat - | tar xf -

	_build_image
	_save_app_data
	_handle_containers
}

function _build_image {
	builder="$(cat Seafile | grep builder | awk '{print $2}')"

	_announce "Getting last version of builder image"

	_tcp_docker pull "$builder" 1> /dev/null

	_announce "Building $image_name with $builder"

	image_name="$role/$repository"
	sti build . "$builder" "$image_name" -U "tcp://localhost:2375" 2>&1 | _indent_output

	registry_image_name="localhost:5000/$image_name:$revision"
	_tcp_docker tag "$image_name" "$registry_image_name"

	_announce "Pushing resulting image to the cluster's registry, be patient..."

	_tcp_docker push "$registry_image_name" 1> /dev/null | _indent_output
}

function _save_app_data {
	_announce "Saving information to distributed KV storage"

	# cns stand for consul namespace
	app_cns="apps/$role/$repository"
	revisions_cns="$app_cns/revisions"
	latest_revision_key="$revisions_cns/latest"
	previous_revision_key="$revisions_cns/previous"

	consul.kv.set $previous_revision_key $(consul.kv.get $latest_revision_key)
	consul.kv.set $latest_revision_key $revision


	revision_data="$(printf '{"receiver":"%s","role":"%s", "date":"%s"}' \
	    "$(hostname)" "$(date --iso-8601=seconds)" "$role")"

	consul.kv.set $revisions_cns/$revision "$revision_data"

	desired_instances="$(consul.kv.get "$app_cns/instances")"

	if [[ -z "$desired_instances" ]]; then
		desired_instances=1
		consul.kv.set "$app_cns/instances" $desired_instances
	fi
}

function _handle_containers {
	# containers ns
	ctr_cns="containers/$role/$repository"
	for i in $(seq "$desired_instances"); do
		consul.kv.set "$ctr_cns.$i/state" "init"
	done

	_announce "Waiting for instances to start"

	wait_cycles=0
	until [[ "$running" != "$desired_instances" ]] || [ $wait_cycles -eq 4 ]; do
	   	# sleep at the beginning, allows instances to boot
	   	sleep 5
		$(( wait_cycles++ ))
		echo "Some units missing, sleeping 5s"
	done

	if [[ "$running" != "$desired_instances" ]]; then
		echo "     ERROR: Some units didn't boot properly, manual intervention required"
		exit 1
	else
		_announce "$desired_instances instances of $repository are now running"
	fi
}