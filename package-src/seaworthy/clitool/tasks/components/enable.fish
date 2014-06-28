function task.components.enable.run
	# handle --force flag to allow reinstall?
	set -g component $argv[1]
	set -g target_dir "$components_target/$component"

	log.title "Enabling $component component"

	_copy_component
 	_common.clean_broken_links
 	_common.run_hook "before-enable" 2>| atn.indent 
 	_compile_templates
 	_check_consul_config
 	_link_consul_config
 	_link_events
 	_link_checks
 	_link_binaries
 	_enable_units
 	_common.run_hook "after-enable" 2>| atn.indent 

 	atn.done "Successfully enabled $component component"
	
end

function _fail_with_cleanup
	log.error "error: $argv"
	if path.is.dir "$target_dir"
		echo "Force removing copied component directory"
		rm -rf "$target_dir"
	end
	_common.clean_broken_links
	echo "Component activation failed"
	exit 1
end

function _check_consul_config
	set -l consul_dir "$target_dir/consul"
	path.is.dir "$consul_dir" ; or return 0
	log.step "Checking syntax of consul config files"
	for config_file in (find "$consul_dir" -name "*.json")
		jq -n -f "$config_file" > /dev/null \
		; or _fail_with_cleanup "$config_file isn't valid JSON"
	end	
end

function _link_consul_config
	set -l consul_dir "$target_dir/consul"
	path.is.dir "$consul_dir" ; or return 0
	log.step "Linking consul config files:"
	for config_file in (find "$consul_dir" -name "*.json")
		set -l filename (basename $config_file)
		set -l destination_file "$cluster_dir/consul/$filename"
		echo "$filename" | atn.indent
		ln -s "$config_file" "$destination_file"
	end
end

function _link_binaries
	for executable_dir in bin sbin
		set -l bin_dir "$target_dir/$executable_dir"
		path.is.dir "$bin_dir" ; or break
		log.step "Linking exectuables to /usr/$executable_dir"
		for file in (find "$bin_dir" -type f -executable)
			set -l filename (basename "$file")
			set -l target_file "/usr/$executable_dir/$filename"
			if path.exists "$target_file"
				_fail_with_cleanup "$target_file exists and collides with $file"
			end
			echo "$filename" | atn.indent
			ln -s "$file" "$target_file"
		end
	end
end

function _link_events
	set -l events_dir "$target_dir/events"
	path.is.dir "$events_dir" ; or return 0
	for event_bin in (find "$events_dir" -type f -executable)
		set -l filename (basename $event_bin)
		set -l destination_file "$cluster_dir/events/$filename"
		log.step "Linking '$event_bin' event handler"
		ln -s "$event_bin" "$destination_file"
	end
end

function _link_checks
	set -l checks_dir "$target_dir/checks"
	path.is.dir "$checks_dir" ; or return 0
	for check_bin in (find "$checks_dir" -type f -executable)
		set -l filename (basename $check_bin)
		set -l destination_file "$cluster_dir/checks/$filename"
		log.step "Linking '$check_bin' check"
		ln -s "$check_bin" "$destination_file"
	end
end


function _link_events
	set -l events_dir "$target_dir/events"
	path.is.dir "$events_dir" ; or return 0
	for event_bin in (find "$events_dir" -type f -executable)
		set -l filename (basename $event_bin)
		set -l destination_file "$cluster_dir/events/$filename"
		log.step "Linking '$event_bin' event handler"
		ln -s "$event_bin" "$destination_file"
	end
end

function _copy_component
	set -l source_dir (path.resolve $component $component_sources)
	if test "$source_dir"
		log.step "Source of $component component found in $source_dir"
		path.is.dir "$target_dir" ; and atn.done "Component is already enabled, skipping"
		log.step "Copying to $target_dir"
		cp -R "$source_dir" "$target_dir/"
	else
		_fail_with_cleanup "unable to find $component in $component_sources"
	end
end

function _compile_templates
	set -l templates (find $target_dir -name "_*.bit")
	test "$templates" ; or return 0
	log.step "Compiling templates:"
	for template_file in $templates
		functions -q bit.compile_replace ; or module.require bit
		set -l filename (basename "$template_file")
		set -l destination_filename (echo "$filename" | sed -E 's/_(.*)(\.bit)/\1/')
		
		set -l destination_file (dirname $template_file)/$destination_filename
		
		echo "$filename > $destination_filename" | atn.indent
		bit.compile_template $template_file $destination_file
	end
end

function _enable_units
	set -l units_dir "$target_dir/units"
	if path.is.dir "$units_dir"
		for unit in (find $units_dir -type f)
			log.step "Enabling" (basename $unit)
			log.debug "unit file: $unit"
			systemctl enable "$unit" 2>| atn.indent
		end
		log.step "Reloading systemd daemon"
		systemctl daemon-reload
	end
end
