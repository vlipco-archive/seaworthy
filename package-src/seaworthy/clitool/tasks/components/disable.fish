function task.components.disable.run
	# assign reusable global vars
	set component (sanitize_arg $argv[1]); shift
	set target_dir "$COMP_TARGETS/$component"

	_common.run_hook "before-disable"
	_disable_units
	_remove_dir
	# in this case there's not after-disable hook
	# because the file's already gone
	_common.clean_broken_links
	
	echogreen "Successfully disabled $component component"
end

function _disable_units
	set -l units_dir "$target_dir/units"
	if atn.path.dir? "$units_dir"
		for unit in (find $units_dir -type f)
			set -l unit_name (basename $unit)
			atn.info "Stopping $unit_name ... "
			systemctl stop "$unit_name" ; or echo "... ignoring"
			atn.info "Disabling $unit_name ... "
			systemctl disable "$unit_name" ; or echo "... ignoring"
		end
		atn.info "Reloading systemd daemon"
		systemctl daemon-reload
	end
end

function _remove_dir
	atn.path.dir? "$target_dir" ; or atn.end "Component is not enabled, skipping"
	atn.info "Removing $target_dir"
	rm -rf "$target_dir"
end