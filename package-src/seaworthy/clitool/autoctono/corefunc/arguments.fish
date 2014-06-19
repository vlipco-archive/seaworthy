function atn.named_arguments -a function_name
	set -l definition (functions $function_name | head -n 1)
	if echo $definition | grep -qG '\-\-argument'
		# split by the --options, only take arguments, then remove the option
		# name and you have the named params then new lines for easy iteration
		echo "$definition" | sed 's/--/\n/g' | grep 'argument' \
		| sed 's/argument //' | sed 's/ /\n/g'
		return 0
	else
		# no named arguments where defined
		return 1
	end
end

function atn.self_name
	atn.functions_stack | _atn.print_line 3
end

function atn.caller_name
	atn.functions_stack | _atn.print_line 4
end

function _atn.print_line -a line_number
	cat - | awk "NR=="$line_number"{print;exit}"
end

function atn.functions_stack
	set -l unwanted_chars \"\',“”
	status -t | grep 'in function' \
	| tr -d $unwanted_chars \
	| sed -r 's|in function (\S*)|\1|'
end

function atn.set_rargs --no-scope-shadowing
	if test "$argv"
		atn.debug "Parsing rargs of '"(atn.self_name)"' function"
		set -l rargs_left (count (atn.named_arguments (atn.self_name)))
		set rargs_left (math $rargs_left + 1)

		if set -q argv[$rargs_left]
			atn.debug "Starting rargs in argv[$rargs_left]"
			set rargs $argv[$rargs_left..-1]
		else
			atn.debug "Function was called with no rargs, making empty list"
			set rargs
		end
	else
		atn.debug "Skipped parsing of rargs from empty argv in "(atn.self_name)" function"
	end
end
