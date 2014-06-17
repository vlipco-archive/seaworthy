# sligthly modified version of 
# Progrium's conulkv:based in http://git.io/XLm7JA

function btask.consul.kv.run {
	consul.ensure_leader_exists
	# remove / in the beginning of the key
	local key="$(echo "$2" | sed 's|^/||')"
	case "$1" in
		raw_get)
			consul.kv.raw_get "$key" ;;
		get)
			consul.kv.get "$key" ;;
		set)
			consul.kv.set "$key" ;;
		del)
			consul.kv.del "$key" ;;
		ls)
			consul.kv.ls "$key" ;;
		*)
			echo "Unkown command"
			exit 1
	esac
}