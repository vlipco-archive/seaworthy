_next_index () {
	# gets the largest ModifyIndex to use in the next cycle
	jq 'sort_by(.ModifyIndex) | reverse | .[0].ModifyIndex'
}

_watch_loop() {
	local index="0"
	while true; do

		echo "Performing blocking recursive query with index=$index"
		local url="$CONSUL/v1/kv/$key?recurse&index=$index"
		data="$(curl -s "$url" | jq -r '.' )"
		
		echo "Query cycle completed, executing handler command '$handler_cmd'"
		echo $data | $handler_cmd || b.error "Handler command failed"
		
		index="$(echo $data | _next_index)"

	done
}

function btask.consul.watch.run {
	consul.ensure_leader_exists

	# remove / in the beginning of the key
	key="$(echo "$1" | sed 's|^/||')" ; shift
	handler_cmd="${@:-cat}"
	
	local kv="swrth consul kv"
	while [[ -z "$($kv ls $key)" ]] && [[ -z "$($kv get $key)" ]]; do
		echo "Key '$key' is currently empty or has no children, sleeping for 15s"
		sleep 15
	done		
		
	_watch_loop
}
