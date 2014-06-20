function task.components.enable.run
	# handle --force flag to allow reinstall?
	
	# assign reusable global vars
	set component (sanitize_arg $argv[1]); shift
	set target_dir "$components_target/$component"

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
	
end

function _fail_with_cleanup
	atn.error "Error: $argv[1]"
	if path.dir? "$target_dir"
		echo "Force removing copied component directory"
		rm -rf "$target_dir"
	end
	_common.clean_broken_links
	echo "Component activation failed"
	exit 1
end

function _check_consul_config
	set -l consul_dir "$target_dir/consul"
	path.dir? "$consul_dir" ; or return 0
	atn.info "Checking syntax of consul config files"
	for config_file in (find "$consul_dir" -name "*.json")
		jq -n -f "$config_file" > /dev/null \
		; or _fail_with_cleanup "$config_file isn't valid JSON"
	end	
end

function _link_consul_config
	set -l consul_dir "$target_dir/consul"
	path.dir? "$consul_dir" ; or return 0
	atn.info "Linking consul config files:"
	for config_file in (find "$consul_dir" -name "*.json")
		set -l filename (basename $config_file)
		set -l destination_file "$cluster_dir/consul/$filename"
		echo "  $filename"
		ln -s "$config_file" "$destination_file"
	end
end

function _link_binaries
	for executable_dir in bin sbin
		set -l bin_dir "$target_dir/$executable_dir"
		path.dir? "$bin_dir" ; or break
		atn.info "Linking exectuables to /usr/$executable_dir"
		for file in (find "$bin_dir" -type f -executable)
			set -l filename (basename "$file")
			set -l target_file "/usr/$executable_dir/$filename"
			if path.exists "$target_file"
				_fail_with_cleanup "$target_file exists and collides with $file"
			end
			echo "  $filename"
			ln -s "$file" "$target_file"
		end
	end
end

function _link_events
	set -l events_dir "$target_dir/events"
	path.dir? "$events_dir" ; or return 0
	for event_bin in (find "$events_dir" -type f -executable)
		set -l filename (basename $event_bin)
		set -l destination_file "$cluster_dir/events/$filename"
		atn.info "Linking '$event_bin' event handler"
		ln -s "$event_bin" "$destination_file"
	end
end

function _link_checks
	set -l checks_dir "$target_dir/checks"
	path.dir? "$checks_dir" ; or return 0
	for check_bin in (find "$checks_dir" -type f -executable)
		set -l filename (basename $check_bin)
		set -l destination_file "$cluster_dir/checks/$filename"
		atn.info "Linking '$check_bin' check"
		ln -s "$check_bin" "$destination_file"
	end
end


function _link_events
	set -l events_dir "$target_dir/events"
	path.dir? "$events_dir" ; or return 0
	for event_bin in (find "$events_dir" -type f -executable)
		set -l filename (basename $event_bin)
		set -l destination_file "$cluster_dir/events/$filename"
		atn.info "Linking '$event_bin' event handler"
		ln -s "$event_bin" "$destination_file"
	end
end

function _copy_component
	if atn.resolve_dir_path "$component" ${component_sources[@]} > /dev/null
		set -l source_dir (atn.resolve_dir_path "$component" ${component_sources[@]})
		atn.info "Source of $component component found in $source_dir"
		path.dir? "$target_dir" ; and atn.end "Component is already enabled, skipping"
		atn.info "Copying to $target_dir"
		cp -R "$source_dir" "$target_dir/"
	else
		_fail_with_cleanup "Unable to find $component in: ${component_sources[@]}"
	end
end

function _compile_templates
	set -l templates (find "$target_dir" -name "_*.bit")
	set -l templates_count (echo $templates | grep -e '^$' -v | wc -l)
	[ "$templates_count" set  = "0" ] ; and return 0
	atn.info "Compiling templates:"
	for template_file in "$templates"
		is_function? bit.compile_replace ; or atn.module.require bit
		set -l filename (basename "$template_file")
		set -l destination_filename (echo "$filename" | sed -E 's/_(.*)(\.bit)/\1/')
		set -l destination_file ${template_file/$filename/$destination_filename}
		echo "  $filename"
		bit.compile_template "$template_file" "$destination_file"
	end
end

function _enable_units
	set -l units_dir "$target_dir/units"
	if path.dir? "$units_dir"
		for unit in (find $units_dir -type f)
			atn.info "Enabling (basename $unit)"
			systemctl enable "$unit"
		end
		atn.info "Reloading systemd daemon"
		systemctl daemon-reload
	end
end
