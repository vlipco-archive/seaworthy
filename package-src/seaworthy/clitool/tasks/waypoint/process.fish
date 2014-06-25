function task.waypoint.process.run
	#cat -
	# requires past this point will fail!
	#cd (atn.get atn.working_dir)

	#netlog `pwd`
	#while read oldrev newrev refname
	while cat - | read oldrev newrev refname
      # Only run this script for the master branch. You can remove this 
      # if block if you wish to run it for others as well.
      if [ "$refname" = "refs/heads/master" ] 
 
        git archive $newrev | _process "$RECEIVE_REPO" "$newrev"
 
        set rc $status
        if [ $rc != 0 ] 
          echo "      ERROR: failed on rev $newrev - push denied"
          exit $rc
        end
      end
    end
end

function _announce -a msg
  log.info "---> $msg"
end

function _indent_output
  sed -u 's/^/     /'
end

function _tcp_docker
	docker -H "tcp://localhost:2375" $argv
end

function _process
	
	consul.ensure_leader_exists

	# variables definition

	set role (echo "$argv[1]" | awk -F'/' '{print $1}')
	set repository (echo "$argv[1]" | awk -F'/' '{print $2}')
	# revision uses only 7 chars?
	set revision $argv[2] #"${2:0:7}"
	set app_folder "$HOME/slugs/$role/$repository"
	set revision_folder "$app_folder/$revision"

	# TODO fail is the role isn't covered in the cluster

	_announce "Saving revision source"

	mkdir -p "$revision_folder"
	cd "$revision_folder"

	cat - | tar xf -

	_build_image
	_save_app_data
	_handle_containers
end

function _build_image
	set builder (cat Seafile | grep builder | awk '{print $2}')

	_announce "Getting last version of builder image"

	_tcp_docker pull "$builder" 1> /dev/null

	_announce "Building $image_name with $builder"

	set image_name "$role/$repository"
	sti build . "$builder" "$image_name" -U "tcp://localhost:2375" 2>&1 | _indent_output

	set registry_image_name "localhost:5000/$image_name:$revision"
	_tcp_docker tag "$image_name" "$registry_image_name"

	_announce "Pushing resulting image to the cluster's registry, be patient..."

	_tcp_docker push "$registry_image_name" > /dev/null | _indent_output
end

function _save_app_data
	_announce "Saving information to distributed KV storage"

	# cns stand for consul namespace
	set app_cns "apps/$role/$repository"
	set revisions_cns "$app_cns/revisions"
	set latest_revision_key "$revisions_cns/latest"
	set previous_revision_key "$revisions_cns/previous"

	consul.kv.set $previous_revision_key (consul.kv.get $latest_revision_key)
	consul.kv.set $latest_revision_key $revision


	set revision_data (printf '{"receiver":"%s","role":"%s", "date":"%s"}' \
	    (hostname) (iso_date) "$role")

	consul.kv.set "$revisions_cns/$revision" "$revision_data"

	set desired_instances (consul.kv.get "$app_cns/instances")

	if [ -z "$desired_instances" ]
		set desired_instances 1
		consul.kv.set "$app_cns/instances" $desired_instances
	end
end

function _running_instances_of
	echo 0
end

function _handle_containers
	# containers ns
	set ctr_cns "containers/$role/$repository.$revision"
	for i in (seq "$desired_instances")
		consul.kv.set "$ctr_cns.$i/state" "init"
	end

	_announce "Waiting for instances to start"

	set running 0
	set wait_cycles 0

	# indent output with the rest
	echo -n "     "
	while [ "$running" -eq "$desired_instances" -o $wait_cycles -eq 30 ]
	   	# sleep at the beginning, allows instances to boot
	   	sleep 1
		set wait_cycles (math $wait_cycles+1)
		set running (_running_instances_of "$role/$repository")
		echo -n "."
	end

	# break the line for correct format
	echo

	if [ "$running" !set   "$desired_instances" ]
		echo "     ERROR: Some units didn't boot properly, manual intervention required"
		exit 1
	else
		_announce "$desired_instances instances of $repository are now running"
	end
end