function btask.components.disable.run {
	# assign reusable global vars
	component=$(sanitize_arg $1); shift
	target_dir="$COMP_TARGETS/$component"

	_common.run_hook "before-disable"
	_disable_units
	_remove_dir
	# in this case there's not after-disable hook
	# because the file's already gone
	_common.clean_broken_links
}

function _disable_units {
	local units_dir="$target_dir/units"
	if b.path.dir? "$units_dir"; then
		for unit in $(find $units_dir -type f); do
			local unit_name=$(b.path.filename $unit)
			echo -n "Stopping $unit_name ... "
			systemctl stop "$unit_name" || echo "... ignoring"
			echo "Disabling $unit_name ... "
			systemctl disable "$unit_name" || echo "... ignoring"
		done
		echo "Reloading systemd daemon"
		systemctl daemon-reload
	fi
}

function _remove_dir {
	b.path.dir? "$target_dir" || b.done "Component is not enabled, skipping"
	echo "Removing $target_dir"
	rm -rf "$target_dir"
}