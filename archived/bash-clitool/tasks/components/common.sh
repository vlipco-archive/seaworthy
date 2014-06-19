## stuff exposed to all components subcommands

CLUSTER_DIR="/var/cluster/active"
COMP_TARGETS="$CLUSTER_DIR/components"

COMP_SOURCES[0]="/usr/local/lib/seaworthy/components"
COMP_SOURCES[1]="/usr/lib/seaworthy/components"

function btask.components.common.run {
	b.module.require extras
	b.module.require path
}

function _common.run_hook {
	local hook_name="$1"
	local hook_path="$target_dir/hooks/$hook_name"
	if b.path.file? "$hook_path"; then
		b.info "Running $hook_name hook"
		$hook_path || b.abort "$hook_name didn't exit with 0"
	fi
}

function _common.clean_broken_links {
	#b.info "Cleaning symlinks"
	for folder in /etc/systemd/system /usr/bin /usr/sbin /var/cluster/active/checks /var/cluster/active; do
		b.path.dir? $folder || break
		for broken in $(find -L "$folder" -type l); do
			# TODO add verbose flag to print this
			#echo "Removing broken link $broken"
			rm $broken
		done
	done
}