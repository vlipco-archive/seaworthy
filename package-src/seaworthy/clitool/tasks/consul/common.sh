CONSUL="127.0.0.1:8500"

function btask.consul.common.run () {
	b.module.require extras
}

function _ensure_leader_exists {
	_current_leader &> /dev/null || b.abort "no cluster leader"
}

function _current_leader {
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