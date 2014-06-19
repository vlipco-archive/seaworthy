#!/usr/bin/env fish

function named_arguments -a function_name
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

function self_name
	functions_stack | print_line 3
end

function caller_name
	functions_stack | print_line 4
end

function print_line -a line_number
	cat - | awk "NR=="$line_number"{print;exit}"
end

function functions_stack
	status -t | grep 'in function' | sed -r 's/.*“(\w*)”.*/\1/'
end

function parse_rargs_from --no-scope-shadowing
	count $argv
	set -l rargs_left (count (named_arguments (self_name)))
	set rargs_left (math $rargs_left + 1)
	echo "Starting in $rargs_left"
	set rargs $argv[$rargs_left..-1]
end

function main -a name
	parse_rargs_from $argv
	echo $rargs
end

main "david" "other" "other!"