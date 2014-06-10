function btask.components.run () {
	local subcomands_array=(enable disable refresh)
	cmd="$1"; shift
	if in_array? "$cmd" subcomands_array; then
		local fname=$(sanitize_arg "_${cmd}_cmd")
		eval "$fname" $@
	else
		print_e "Unknown subcommand '$cmd'."
		echo -n "Try one of: "
		printf "%s, " "${subcomands_array[@]}" | sed 's/,\s$//i'
		echo "."
		exit 2
	fi
}

## for the given component install consul
## config file or compile them, enable systemd units
## with the component name or all those in a folder with that name
## finally, trigger the component hook if it exists
function _enable_cmd () {
	component="$1"; shift
	echo "Enabling $component component"
	return 0
}

## stop & disable units, remove the links entirely form systemd
## remove consul config files
## trigger component disable hook if present
function _disable_cmd () {
	component="$1"; shift
	echo "Disabling $component component"
	return 0	
}

## for all active components, all source files are
## recopied and all templates are recompiled
## this is equivalent to disable/enable for every component
function _refresh_cmd () {
	echo "Refresh all active components"
	return 0	
}