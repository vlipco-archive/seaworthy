function btask.harbor.common.run () {
	b.module.require extras
	b.module.require consul
}

function _tcp_docker {
	docker -H "tcp://localhost:2375" $@
}

# of all the existing offers for a given app
# how many are marked as owned by this node
function _local_count_of {
	# get only the containes descriptions that have an associated owner
	local keys="$(consul.kv.raw_get "containers/external/$1.?recurse&keys" | grep owner)"
	local count=0
	for key in $keys; do
		local val="$(consul.kv.get $key)"
		[[ "$val" == "$(hostname)" ]] && count=$(( $count + 1 ))
	done
	echo $count
}

# max amount of offer of a given app
# that this node can take, equals to:
# desired_instances / matching_harbors + 1
function _max_count_of {
	local instances=$(consul.kv.get "apps/external/$1/instances") 
	if [[ -n "$instances" ]]; then
		local harbors=$(_matching_harbors_count)
		echo "$(( $instances / $harbors ))"
	else
		echo 0
	fi
}

# how many harbors with the same role
# exists in the catalog
function _matching_harbors_count {
	consul.api.raw_get "catalog/service/harbor" | jq '.|length'
}

function _apps_in_role {
	consul.kv.ls "apps/$1" | awk -F'/' '{print $1}' | sort -u
}

# list of items in the format app.n, e.g: rubyapp.2
function _offers_lists {
	swrth consul kv ls containers/external | grep state | awk -F'/' '{print $1}'
}

function _offer_owner {
	consul.kv.get "containers/external/$1/owner"
}

function _offer_has_owner {
	[[ -n "$(_offer_owner "$1")" ]]
	return $?
}

function _acquire_offer {
	consul.kv.set "containers/external/$1/owner" "$(hostname)"
}

function _is_offer_mine {
	[[ "$(_offer_owner "$1")" == "$(hostname)" ]]
	return $?
}

function _my_offers {
	for offer in $(_offers_lists); do
		if _is_offer_mine "$offer"; then
			echo "$offer"
		fi
	done
}