function btask.harbor.balance.run () {
	b.module.require consul
	b.info "Balancing local harbor $(date)"
	_balance_containers_ownership
	_handle_containers
}


function _balance_containers_ownership {
	for offer in $(_offers_lists); do
		if ! _offer_has_owner "$offer"; then
			b.info "I should get $offer"
			_acquire_offer "$offer"
			if _is_offer_mine "$offer"; then
				b.info "is mine!!"
			else
				echo "didn't get it :("
				echo "it belongs to: $(_offer_owner "$offer")"
			fi
		else
			echo "Ignoring $offer since it's already owner by $(_offer_owner "$offer")"
		fi
	done
}

function _handle_containers {
	local registry="registry.service.consul:5000"

	for offer in $(_my_offers); do
		local offer_app="$(echo "$offer" | awk -F'.' '{print $1}')"
		local offer_tag="$(echo "$offer" | awk -F'.' '{print $2}')"
		local image_name="$registry/external/$offer_app:$offer_tag"
		echo "pulling $image_name"
		_tcp_docker pull "$image_name" 1> /dev/null
		if ! _tcp_docker ps | grep -q -G "$offer"; then
			echo "Running $image_name"
			_tcp_docker rm "$offer" || true
			_tcp_docker run -dt --name "$offer" -p :5000 \
			  -e CONSUL_NAME="$offer_app" -e CONSUL_5000_TAGS="$offer_tag" \
			  "$image_name"
		fi
	done
	local offers_ls="$(_my_offers)"
	for ctr in $(_tcp_docker ps -q); do
		local ctr_name="$(_container_name "$ctr")"
		if echo $offers_ls | grep -q -G "$ctr"; then
			echo "Marking $ctr as running"
			consul.kv.set "containers/external/$ctr/state" "running"
		fi
	done
}
