# sligthly modified version of 
# Progrium's conulkv:based in http://git.io/XLm7JA

function task.consul.kv.run -a action key
	if test $action
		consul.ensure_leader_exists
		# remove / in the beginning of the key
		set -q key; and set key (echo $key | sed 's|^/||')
		switch $action
			case "raw_get"
				consul.kv.raw_get $key
			case "get"
				consul.kv.get $key
			case "set"
				atn.set_rargs $argv
				consul.kv.set $key $rargs
			case "del"
				consul.kv.del $key
			case "ls"
				consul.kv.ls $key
			case "*"
				atn.abort "unkown command"
		end
	else
		atn.abort "missing desired action argument"
	end
end