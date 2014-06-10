

function component.disable_units() {
	local target=`component.target_path`
	local units_dir="$target/units"
	if b.path.dir? "$units_dir"; then
		local units=`find $units_dir`

		echo "Disabling and stopping systemd units"
		for unit in find "$units_dir" -type f; do
			echo -n "  Stopping $unit ... "
			systemctl stop $unit
			echo "Disabling $unit"
			systemctl disable $unit
		done
		
		echo "Reloading systemd daemon"
		systemctl daemon-reload
	fi
}

function component.remove_dir() {
	local target=`component.target_path`
	if b.path.dir? "$target"; then
		echo "Removing $target"
		rm -rf "$target"
	else
		b.done "Component is not enabled, skipping"
	fi

}

function btask.components.disable.run: () {
	component=$(sanitize_arg $1); shift
	b.set "swrth.target_component" "$component"
	
	echo "Disabling $component component"
	component.run_hook "before-disable"
	component.remove_dir
	component.remove_links
	component.disable_units
	component.run_hook "after-disable"
}




function component.remove_links() {
	echo "!! component.remove_links"
}