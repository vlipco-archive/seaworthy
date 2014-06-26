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

function consul.url -a url
	echo (atn.get consul.addr)$url
end

function consul.ensure_leader_exists
	consul.leader > /dev/null ; or atn.abort "no cluster leader"
end

function consul.kv.set -a key value
	curl -s -X PUT -d "$value" (consul.url "/v1/kv/$key") > /dev/null
end

function consul.kv.get -a key
	set target_url (consul.url "/v1/kv/$key")
	log.debug "Getting $target_url"
	curl -s $target_url | jq -r .[].Value | base64 -d | sed 's|$|\n|'
end

function consul.kv.ls -a key
	if [ -z "$key" ]
		curl -s (consul.url "/v1/kv/?keys") | jq -r .[]
	else
		curl -s (consul.url "/v1/kv/$key/?keys") | jq -r .[] | sed "s|$key/||"
	end
end

function consul.kv.del -a key
	curl -s -X DELETE (consul.url "/v1/kv/$key") > /dev/null
end

function consul.kv.raw_get -a key
	consul.api.raw_get "kv/$key" | jq -r .[]
end

function consul.api.raw_get -a uri
	curl -s (consul.url "/v1/$uri")
end
