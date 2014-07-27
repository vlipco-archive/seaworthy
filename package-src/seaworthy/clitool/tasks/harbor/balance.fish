function task.harbor.balance.run
	log.info "Balancing local harbor" (date)

	log.debug "Handling containers state"
	
	set -l registry (consul.api.raw_get "catalog/service/registry" | jq -r '.[0].Address')

	for ctr in (ctr.mine)
		set -l ctr_app (echo "$ctr" | awk -F'.' '{print $1}')
		set -l ctr_tag (echo "$ctr" | awk -F'.' '{print $2}')
		#set -l image_name "$registry:5000/external/$ctr_app:$ctr_tag"
		set -l image_name "registry.service.consul:5000/external/$ctr_app:$ctr_tag"
		
		if not _tcp_docker ps | grep -q -G "$ctr"
			log.info "Pulling $image_name"
			_tcp_docker pull "$image_name" 1> /dev/null
			log.info "Running $ctr"
			_tcp_docker rm "$ctr" ^&- ; or true
			set consul_env (_docker_env $ctr_app)
			eval _tcp_docker run -dt --name "$ctr" -P \
			  -e CONSUL_NAME="$ctr_app" -e CONSUL_TAGS="$ctr_tag" $consul_env \
			  "$image_name"
		else
			log.info "$ctr is already running"
		end
	end

	# todo handle container removal

	for ctr in (docker ps -q)
		set name (_container_name $ctr)
		# check if format is xxx.yyy.d, e.g: ruby.4eef16f.1
		if echo $name | grep -qE '^[^.]*\.[^.]*\.[0-9]+'
			# stop this container unless an offer for it exists
			if not ctr.mine | grep -qG $name
				echo "Container $name must be stopped"
				_tcp_docker stop $ctr
				_tcp_docker rm -f $ctr
			end
		end
	end

	atn.done "Harbor has been balanced"

end