function task.harbor.balance.run
	log.info "Balancing local harbor" (date)
	_balance_containers_ownership
	_handle_containers
end


function _balance_containers_ownership
	log.debug "Getting offer list to balance"
	for offer in (_offers_lists)
		if ! _offer_has_owner "$offer"
			log.info "I should get $offer"
			_acquire_offer "$offer"
			if _is_offer_mine "$offer"
				log.info "is mine!!"
			else
				echo "didn't get it"
				echo "it belongs to:" (_offer_owner "$offer")
			end
		else
			echo "Ignoring $offer since it's already owner by" (_offer_owner "$offer")
		end
	end
end

function _handle_containers
	log.debug "Handling containers state"
	set -l registry "registry.service.consul:5000"

	for offer in (_my_offers)
		set -l offer_app (echo "$offer" | awk -F'.' '{print $argv[1]}')
		set -l offer_tag (echo "$offer" | awk -F'.' '{print $argv[2]}')
		set -l image_name "$registry/external/$offer_app:$offer_tag"
		echo "pulling $image_name"
		_tcp_docker pull "$image_name" 1> /dev/null
		if ! _tcp_docker ps | grep -q -G "$offer"
			echo "Running $image_name"
			_tcp_docker rm "$offer" ; or true
			_tcp_docker run -dt --name "$offer" -p :5000 \
			  -e set CONSUL_NAME "$offer_app" -e CONSUL_5000_TAGS="$offer_tag" \
			  "$image_name"
		end
	end
	set -l offers_ls (_my_offers)
	for ctr in (_tcp_docker ps -q)
		set -l ctr_name (_container_name "$ctr")
		if echo $offers_ls | grep -q -G "$ctr"
			echo "Marking $ctr as running"
			consul.kv.set "containers/external/$ctr/state" "running"
		end
	end
end
