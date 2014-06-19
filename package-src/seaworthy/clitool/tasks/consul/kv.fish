# sligthly modified version of 
# Progrium's conulkv:based in http://git.io/XLm7JA

function task.consul.kv.run
	if set -q argv[1]
		consul.ensure_leader_exists

		set -l key
		# remove / in the beginning of the key
		set -q argv[2] ; and set key (echo $argv[2] | sed 's|^/||')

		switch $argv[1]
			case "raw_get"
				consul.kv.raw_get $key
			case "get"
				consul.kv.get $key
			case "set"
				consul.kv.set $key $argv[3]
			case "del"
				consul.kv.del $key
			case "ls"
				consul.kv.ls $key
			case "*"
				atn.abort "Unkown command"
		end
	else
		atn.abort "Missing desired action argument"
	end
end