function btask.components.enable.run  {

	# assign reusable global vars
	component=$(sanitize_arg $1); shift
	target_dir="$COMP_TARGETS/$component"

	_common.clean_broken_links
	
	_copy_component	
	_common.run_hook "before-enable"
	_compile_templates
	_link_binaries
	_enable_units
	_common.run_hook "after-enable"
}

function _copy_component {
	local source_dir=$(b.resolve_dir_path "$component" ${COMP_SOURCES[@]})
	if [[ -z "$source_dir" ]]; then
		b.abort "Unable to find $1 in: ${COMP_SOURCES[@]}"
	fi
	echo "Component found in $source_dir"
	b.path.dir? "$target_dir" && b.done "Component target exists, skipping"
	echo "Copying to $target_dir"
	cp -R "$source_dir" "$target_dir/"
}

function _compile_templates {
	for template_file in $(find "$target_dir" -name "*.bst"); do
		is_function? bst.compile_replace || b.module.require bst
		local filename=$(b.path.filename "$template_file")
		echo "Compiling $filename"
		bst.compile_replace "$template_file"
	done
}

function _enable_units {
	local units_dir="$target_dir/units"
	if b.path.dir? "$units_dir"; then
		for unit in $(find $units_dir -type f); do
			echo "Enabling $(b.path.filename $unit)"
			# TODO replace? force?
			systemctl enable "$unit"
		done
		echo "Reloading systemd daemon"
		systemctl daemon-reload
	fi
}


function _link_binaries {
	for executable_dir in bin sbin; do
		local bin_dir="$target_dir/$executable_dir"
		b.path.dir? "$bin_dir" || break
		for file in $(find "$bin_dir" -type f -executable); do
			local filename=$(b.path.filename "$file")
			local target_file="/usr/$executable_dir/$filename"
			if b.path.exists? "$target_file"; then
				# TODO replace? force?
				b.abort "$target_file exists and collides with $file"
			fi
			echo "Linking $filename in /usr/$executable_dir"
			ln -s "$file" "$target_file"
		done
	done
}