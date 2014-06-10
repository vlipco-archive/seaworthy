function subcommand.run () {
	cmd="$1"; shift
	local fname=`sanitize_arg "_${cmd}_cmd"`
	if is_function? "$fname"; then
		$fname "$@"
	else
		b.abort "Unknown subcommand '$cmd'."
	fi
}