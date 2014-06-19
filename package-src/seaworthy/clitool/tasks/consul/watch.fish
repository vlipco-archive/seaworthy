_next_index
	# gets the largest ModifyIndex to use in the next cycle
	jq 'sort_by(.ModifyIndex) | reverse | .[0].ModifyIndex'
end

_watch_loop
	set -l index "0"
	while true

		echo "Performing blocking recursive query with set index $index"
		set -l url "$CONSUL/v1/kv/$key?recurse&set index $index"
		set data (curl -s "$url" | jq -r '.' )
		
		echo "Query cycle completed, executing handler command '$handler_cmd'"
		echo $data | $handler_cmd ; or atn.error "Handler command failed"
		
		set index (echo $data | _next_index)

	end
end

function task.consul.watch.run
	consul.ensure_leader_exists

	# remove / in the beginning of the key
	set key (echo "$argv[1]" | sed 's|^/; or') ; shift
	set handler_cmd "${@:-cat}"
	
	set -l kv "swrth consul kv"
	while [ -z ($kv ls $key)" ] ; and [ -z "($kv get $key) ]
		echo "Key '$key' is currently empty or has no children, sleeping for 15s"
		sleep 15
	end		
		
	_watch_loop
end
