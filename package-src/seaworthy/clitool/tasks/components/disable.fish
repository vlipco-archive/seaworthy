function task.components.disable.run
	# assign reusable global vars
	set -g component $argv[1]
	set -g target_dir "$components_target/$component"

	_common.run_hook "before-disable"
	_disable_units
	_remove_dir
	# in this case there's not after-disable hook
	# because the file's already gone
	_common.clean_broken_links
	
	atn.done "Successfully disabled $component component"
end

function _disable_units
	log.debug "disabling units"
	set -l units_dir "$target_dir/units"
	if path.is.dir $units_dir
		for unit in (find $units_dir -type f)
			set -l unit_name (basename $unit)
			
			log.info "Stopping $unit_name ... "
			systemctl stop "$unit_name" 2>| sed 's/^/  /'
			or echo "... ignoring"
			
			log.info "Disabling $unit_name ... "
			systemctl disable "$unit_name" 2>| sed 's/^/  /'
			or echo "... ignoring"
		end
		log.info "Reloading systemd daemon"
		systemctl daemon-reload
	end
end

function _remove_dir
	log.debug "removing $target_dir"
	path.is.dir $target_dir ; or atn.done "Component is not enabled, skipping"
	log.info "Removing $target_dir"
	rm -rf "$target_dir"
end