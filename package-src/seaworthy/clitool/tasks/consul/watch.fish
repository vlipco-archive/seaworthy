function _next_index
	# gets the largest ModifyIndex to use in the next cycle
	jq 'sort_by(.ModifyIndex) | reverse | .[0].ModifyIndex'
end

function _watch_loop
	set -l index 0
	while true

		while _data_missing
			echo "Key '$key' is currently empty or has no children, sleeping for 15s"
			sleep 15
		end	

		echo "Performing blocking recursive query with set index $index"
		set data (consul.api.raw_get "kv/$key?recurse&index=$index" | jq -r '.' )
		
		echo "Query cycle completed, executing handler command '$handler_cmd'"
		echo $data | eval $handler_cmd ; or log.error "Handler command failed with $status"
		
		set index (echo $data | _next_index)
	end
end

function task.consul.watch.run
	module.require consul
	consul.ensure_leader_exists

	# remove / in the beginning of the key
	set -g key (echo "$argv[1]" | sed 's|^/||')
	set -g handler_cmd "$argv[2..-1]"
		
	_watch_loop
end

function _data_missing
	set list (consul.kv.ls $key)
	set val (consul.kv.get $key)
	test -z "$list"; and test -z "$val"
	return $status
end