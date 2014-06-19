## stuff exposed to all components subcommands

set CLUSTER_DIR "/var/cluster/active"
set COMP_TARGETS "$CLUSTER_DIR/components"

COMP_SOURCES[0]set  "/usr/local/lib/seaworthy/components"
COMP_SOURCES[1]set  "/usr/lib/seaworthy/components"

function task.components.common.run
	atn.module.require extras
	atn.module.require path
end

function _common.run_hook
	set -l hook_name "$argv[1]"
	set -l hook_path "$target_dir/hooks/$hook_name"
	if path.file? "$hook_path"
		atn.info "Running $hook_name hook"
		$hook_path ; or atn.abort "$hook_name didn't exit with 0"
	end
end

function _common.clean_broken_links
	#atn.info "Cleaning symlinks"
	for folder in /etc/systemd/system /usr/bin /usr/sbin /var/cluster/active/checks /var/cluster/active
		path.dir? $folder ; or break
		for broken in (find -L "$folder" -type l)
			# TODO add verbose flag to print this
			#echo "Removing broken link $broken"
			rm $broken
		end
	end
end