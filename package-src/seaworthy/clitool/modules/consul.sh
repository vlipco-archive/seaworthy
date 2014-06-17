CONSUL="127.0.0.1:8500"

function consul.leader {
	if curl -s "$CONSUL" &> /dev/null; then
		leader=$(curl -s "http://127.0.0.1:8500/v1/status/leader" --max-time 1)
		# remove the quotes & roughly check for the format
		leader=$(echo $leader | jq -r '.' | grep -E '^([0-9]|\.|:)*$')

		if [[ -n "$leader" ]] ; then
			echo $leader
			return 0
		else
			echo "null"
			return 1
		fi
	else
		echo "null - No local connection to consul on port 8500"
		return 1
	fi
}

function consul.ensure_leader_exists {
	consul.leader &> /dev/null || b.abort "no cluster leader"
}

function consul.kv.set {
	curl -s -X PUT -d "$2" "$CONSUL/v1/kv/$1" > /dev/null
}

function consul.kv.get {
	curl -s "$CONSUL/v1/kv/$1" | jq -r .[].Value | base64 -d | sed 's/$/\n/'
}

function consul.kv.ls {
	if [[ "$1" == "" ]]; then
		curl -s "$CONSUL/v1/kv/?keys" | jq -r .[]
	else
		curl -s "$CONSUL/v1/kv/$1/?keys" | jq -r .[] | sed "s|$1/||"
	fi
}

function consul.kv.del {
	curl -s -X DELETE -d "$3" "$CONSUL/v1/kv/$1" > /dev/null
}

function consul.kv.raw_get {
	consul.api.raw_get "kv/$1" | jq -r .[]
}

function consul.api.raw_get {
	curl -s "$CONSUL/v1/$1"
}
