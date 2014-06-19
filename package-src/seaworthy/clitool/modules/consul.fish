atn.set consul.addr "127.0.0.1:8500"

function consul.leader
	if curl -s (atn.get consul.addr) > /dev/null
		set leader (curl -s "http://127.0.0.1:8500/v1/status/leader" --max-time 1)
		# remove the quotes & roughly check for the format
		set leader (echo $leader | jq -r '.' | grep -E '^([0-9]|\.|:)*$')

		if [ -n "$leader" ] 
			echo $leader
			return 0
		else
			echo "null"
			return 1
		end
	else
		echo $status
		echo "null - No local connection to consul on port 8500"
		return 1
	end
end

function consul.url
	echo (atn.get consul.addr)$argv[1]
end

function consul.ensure_leader_exists
	consul.leader > /dev/null ; or atn.abort "no cluster leader"
end

function consul.kv.set
	curl -s -X PUT -d "$argv[2]" (consul.url "/v1/kv/$argv[1]") > /dev/null
end

function consul.kv.get
	curl -s (consul.url "/v1/kv/$argv[1]") | jq -r .[].Value | base64 -d | sed 's/$/\n/'
end

function consul.kv.ls
	if [ -z "$argv[1]" ]
		curl -s (consul.url "/v1/kv/?keys") | jq -r .[]
	else
		curl -s (consul.url "/v1/kv/$argv[1]/?keys") | jq -r .[] | sed "s|$argv[1]/; or"
	end
end

function consul.kv.del
	curl -s -X DELETE -d "$argv[3]" (consul.url "/v1/kv/$argv[1]") > /dev/null
end

function consul.kv.raw_get
	consul.api.raw_get "kv/$argv[1]" | jq -r .[]
end

function consul.api.raw_get
	curl -s (consul.url "/v1/$argv[1]")
end
