
## stuff exposed to all components subcommands

COMP_TARGETS="/etc/cluster/components"
COMP_SOURCES[0]="/usr/local/lib/seaworthy/components"
COMP_SOURCES[1]="/usr/lib/seaworthy/components"

function btask.components.common.run {
	b.module.require extras
	b.module.require path
}

function _common.run_hook {
	local hook_name="$1"
	local hook_path="$target_dir/$hook_name"
	if b.path.file? "$hook_path"; then
		echo "Running $hook_name hook"
		$hook_path || b.abort "$hook_name didn't exit with 0"
	fi
}

function _common.clean_broken_links {
	for folder in /etc/systemd/system /usr/bin /usr/sbin; do
		for broken in $(find -L "$folder" -type l); do
			echo "Removing broken link $broken"
			rm $broken
		done
	done
}