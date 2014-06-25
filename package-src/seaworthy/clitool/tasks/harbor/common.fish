function task.harbor.common.run
	module.require extras
	module.require consul
end

function _tcp_docker
	docker -H "tcp://localhost:2375" $argv
end

# of all the existing offers for a given app
# how many are marked as owned by this node
function _local_count_of
	# get only the containes descriptions that have an associated owner
	set -l keys (consul.kv.raw_get "containers/external/$argv[1].?recurse&keys" | grep "owner")
	set -l count 0
	for key in $keys
		set -l val (consul.kv.get $key)
		[ "$val"  == (hostname) ] ; and set count (math $count+1)
	end
	echo $count
end

# max amount of offer of a given app
# that this node can take, equals to:
# desired_instances / matching_harbors + 1
function _max_count_of
	set -l instances (consul.kv.get "apps/external/$argv[1]/instances") 
	if [ -n "$instances" ]
		set -l harbors (_matching_harbors_count)
		echo (math $instances/$harbors)
	else
		echo 0
	end
end

# how many harbors with the same role
# exists in the catalog
function _matching_harbors_count
	consul.api.raw_get "catalog/service/harbor" | jq '.|length'
end

function _apps_in_role
	consul.kv.ls "apps/$argv[1]" | awk -F'/' '{print $argv[1]}' | sort -u
end

# list of items in the format app.n, e.g: rubyapp.2
function _offers_lists
	consul.kv.ls containers/external | grep "state" | awk -F'/' '{print $argv[1]}'
end

function _offer_owner
	consul.kv.get "containers/external/$argv[1]/owner"
end

function _offer_has_owner
	test (_offer_owner "$argv[1]")
	return $status
end

function _acquire_offer
	consul.kv.set "containers/external/$argv[1]/owner" (hostname)
end

function _is_offer_mine
	[ (_offer_owner "$argv[1]") == (hostname) ]
	return $status
end

function _my_offers
	for offer in (_offers_lists)
		if _is_offer_mine "$offer"
			echo "$offer"
		end
	end
end

function _container_name
	_tcp_docker inspect --format "{{.Name}}" "$argv[1]" | sed 's|^/||'
end