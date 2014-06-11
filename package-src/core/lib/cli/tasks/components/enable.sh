function btask.components.enable.run  {
	# handle --force flag to allow reinstall?
	
	# assign reusable global vars
	component=$(sanitize_arg $1); shift
	target_dir="$COMP_TARGETS/$component"

	_copy_component
 	_common.clean_broken_links
 	_common.run_hook "before-enable"
 	_compile_templates
 	_check_consul_config
 	_link_consul_config
 	_link_events
 	_link_checks
 	_link_binaries
 	_enable_units
 	_common.run_hook "after-enable"

 	echo
 	echogreen "Successfully enabled $component component"
 	exit 0
	
}

function _fail_with_cleanup {
	b.error "Error: $1"
	if b.path.dir? "$target_dir"; then
		echo "Force removing copied component directory"
		rm -rf "$target_dir"
	fi
	_common.clean_broken_links
	echo "Component activation failed"
	exit 1
}

function _check_consul_config {
	local consul_dir="$target_dir/consul"
	b.path.dir? "$consul_dir" || return 0
	b.info "Checking syntax of consul config files"
	for config_file in $(find "$consul_dir" -name "*.json"); do
		jq -n -f "$config_file" &> /dev/null \
		|| _fail_with_cleanup "$config_file isn't valid JSON"
	done	
}

function _link_consul_config {
	local consul_dir="$target_dir/consul"
	b.path.dir? "$consul_dir" || return 0
	b.info "Linking consul config files:"
	for config_file in $(find "$consul_dir" -name "*.json"); do
		local filename="$(b.path.filename $config_file)"
		local destination_file="$CLUSTER_DIR/consul/$filename"
		echo "  $filename"
		ln -s "$config_file" "$destination_file"
	done
}

function _link_binaries {
	for executable_dir in bin sbin; do
		local bin_dir="$target_dir/$executable_dir"
		b.path.dir? "$bin_dir" || break
		b.info "Linking exectuables to /usr/$executable_dir"
		for file in $(find "$bin_dir" -type f -executable); do
			local filename=$(b.path.filename "$file")
			local target_file="/usr/$executable_dir/$filename"
			if b.path.exists? "$target_file"; then
				_fail_with_cleanup "$target_file exists and collides with $file"
			fi
			echo "  $filename"
			ln -s "$file" "$target_file"
		done
	done
}

function _link_events {
	local events_dir="$target_dir/events"
	b.path.dir? "$events_dir" || return 0
	for event_bin in $(find "$events_dir" -type f -executable); do
		local filename="$(b.path.filename $event_bin)"
		local destination_file="$CLUSTER_DIR/events/$filename"
		b.info "Linking '$event_bin' event handler"
		ln -s "$event_bin" "$destination_file"
	done
}

function _link_checks {
	local checks_dir="$target_dir/checks"
	b.path.dir? "$checks_dir" || return 0
	for check_bin in $(find "$checks_dir" -type f -executable); do
		local filename="$(b.path.filename $check_bin)"
		local destination_file="$CLUSTER_DIR/checks/$filename"
		b.info "Linking '$check_bin' check"
		ln -s "$check_bin" "$destination_file"
	done
}


function _link_events {
	local events_dir="$target_dir/events"
	b.path.dir? "$events_dir" || return 0
	for event_bin in $(find "$events_dir" -type f -executable); do
		local filename="$(b.path.filename $event_bin)"
		local destination_file="$CLUSTER_DIR/events/$filename"
		b.info "Linking '$event_bin' event handler"
		ln -s "$event_bin" "$destination_file"
	done
}

function _copy_component {
	if b.resolve_dir_path "$component" ${COMP_SOURCES[@]} &> /dev/null; then
		local source_dir=$(b.resolve_dir_path "$component" ${COMP_SOURCES[@]})
		b.info "Source of $component component found in $source_dir"
		b.path.dir? "$target_dir" && b.done "Component is already enabled, skipping"
		b.info "Copying to $target_dir"
		cp -R "$source_dir" "$target_dir/"
	else
		_fail_with_cleanup "Unable to find $component in: ${COMP_SOURCES[@]}"
	fi
}

function _compile_templates {
	local templates=$(find "$target_dir" -name "_*.bit")
	local templates_count=$(echo $templates | grep -e '^$' -v | wc -l)
	[[ "$templates_count" == "0" ]] && return 0
	b.info "Compiling templates:"
	for template_file in "$templates"; do
		is_function? bit.compile_replace || b.module.require bit
		local filename=$(b.path.filename "$template_file")
		local destination_filename=$(echo "$filename" | sed -E 's/_(.*)(\.bit)/\1/')
		local destination_file=${template_file/$filename/$destination_filename}
		echo "  $filename"
		bit.compile_template "$template_file" "$destination_file"
	done
}

function _enable_units {
	local units_dir="$target_dir/units"
	if b.path.dir? "$units_dir"; then
		for unit in $(find $units_dir -type f); do
			b.info "Enabling $(b.path.filename $unit)"
			systemctl enable "$unit"
		done
		b.info "Reloading systemd daemon"
		systemctl daemon-reload
	fi
}
