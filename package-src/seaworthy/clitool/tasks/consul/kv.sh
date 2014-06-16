# sligthly modified version of 
# Progrium's conulkv:based in http://git.io/XLm7JA

function btask.consul.kv.run {
	_ensure_leader_exists
	# remove / in the beginning of the key
	local key="$(echo "$2" | sed 's|^/||')"
	case "$1" in
		info)
			curl -s "$CONSUL/v1/kv/$key" | jq -r .[]
			;;
		watch)
			# behaves likes info, no base 64 decoding since it's recursive
			# format: consuklv watch key index timeout
			# we define a default timeout to simplify the formation of the params
			local query_params="wait=${4:-10m}"
			query_params="${query_params}&index=$3"
			curl -s "$CONSUL/v1/kv/$key?recurse&${query_params}" | jq -r .[]
			;;
		get)
			curl -s "$CONSUL/v1/kv/$key" | jq -r .[].Value | base64 -d | sed 's/$/\n/'
			;;
		set)
			curl -s -X PUT -d "$3" "$CONSUL/v1/kv/$key" > /dev/null
			;;
		del)
			curl -s -X DELETE -d "$3" "$CONSUL/v1/kv/$key" > /dev/null
			;;
		ls)
			if [[ "$key" == "" ]]; then
				curl -s "$CONSUL/v1/kv/?keys" | jq -r .[]
			else
				curl -s "$CONSUL/v1/kv/$key/?keys" | jq -r .[] | sed "s|$key/||"
			fi
			;;
		*)
			echo "Unkown command"
			exit 1
	esac
}