## stuff exposed to all components subcommands

set -g cluster_dir "/var/cluster/active"
set -g components_target "$cluster_dir/components"

set -g component_sources[1] "/usr/local/lib/seaworthy/components"
set -g component_sources[2] "/usr/lib/seaworthy/components"

function _common.run_hook -a hook_name
	set -l hook_path "$target_dir/hooks/$hook_name"
	if path.exists $hook_path
		log.info "Running $hook_name hook"
		eval $hook_path ; or atn.abort "$hook_name didn't exit with 0"
	end
end

function _common.clean_broken_links
	#log.info "Cleaning symlinks"
	set clean_dirs "/etc/systemd/system" "/usr/bin" "/usr/sbin" \
	  "/var/cluster/active/checks" "/var/cluster/active"
	for folder in $clean_dirs
		path.is.dir $folder ; or break
		for broken in (find -L "$folder" -type l)
			# TODO add verbose flag to print this
			#echo "Removing broken link $broken"
			rm $broken
		end
	end
end