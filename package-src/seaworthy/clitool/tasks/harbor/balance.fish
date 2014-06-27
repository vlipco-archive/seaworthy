function task.harbor.balance.run
	log.info "Balancing local harbor" (date)

	log.debug "Handling containers state"
	
	set -l registry (consul.api.raw_get "catalog/service/registry" | jq -r '.[0].Address')

	for ctr in (ctr.mine)
		set -l ctr_app (echo "$ctr" | awk -F'.' '{print $1}')
		set -l ctr_tag (echo "$ctr" | awk -F'.' '{print $2}')
		set -l image_name "$registry:5000/external/$ctr_app:$ctr_tag"
		
		if not _tcp_docker ps | grep -q -G "$ctr"
			log.info "Pulling $image_name"
			_tcp_docker pull "$image_name" 1> /dev/null
			log.info "Running $ctr"
			_tcp_docker rm "$ctr" ^- ; or true
			_tcp_docker run -dt --name "$ctr" -P \
			  -e CONSUL_NAME="$ctr_app" -e CONSUL_TAGS="$ctr_tag" \
			  "$image_name"
		else
			log.info "$ctr is already running"
		end
	end

	# todo handle container removal
	atn.done "Harbor has been balanced"

end