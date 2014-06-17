function btask.harbor.balance.run () {
	b.module.require consul
	b.info "!!! balancing $(date)"
	
	_balance_containers_ownership
	_pull_images
	_handle_containers_state
}


function _balance_containers_ownership {
	for offer in $(_offers_lists); do
		if ! _offer_has_owner "$offer"; then
			echo "I should get $offer"
			_acquire_offer "$offer"
			if _is_offer_mine "$offer"; then
				echo "is mine!!"
			else
				echo "didn't get it :("
				echo "it belongs to: $(_offer_owner "$offer")"
			fi
		else
			echo "Ignoring $offer since it's already owner by $(_offer_owner "$offer")"
		fi
	done
}

function _pull_images {
	local registry="registry.service.consul:5000"
	for offer in $(_my_offers); do
		local offer_app="$(echo "$offer" | awk -F'.' '{print $1}')"
		local image_name="$registry/$offer_app"
		echo "pulling $image_name"
	done
}

function _handle_containers_state {
	echo "Handling containers state"
}