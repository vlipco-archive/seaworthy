#!/bin/bash
set -eo pipefail

CONSUL="127.0.0.1:8500"

watch_cycle () {
	# accepts the reference index as param
	local url="$CONSUL/v1/kv/$key?recurse&index=$1"
	curl -s "$url"
}

next_query_index () {
	# gets the largest ModifyIndex to use in the next cycle
	jq 'sort_by(.ModifyIndex) | reverse | .[0].ModifyIndex'
}

watch_loop() {
	local query_index="0"
	while true; do
		echo "Performing blocking recursive query with index=$query_index"
		data="$(watch_cycle $query_index)"
		echo "Query cycle completed, executing handler command"
		echo $data | jq -r '.' | $handler_cmd
		echo "Parsing new index for next cycle"
		query_index="$(echo $data | next_query_index)"
	done
}

if consul-leader &> /dev/null; then
	# remove / in the beginning of the key
	key="$(echo "$1" | sed 's|^/||')" ; shift
	handler_cmd="$@"
	watch_loop
else
	echo "no cluster leader"
	exit 128
fi
