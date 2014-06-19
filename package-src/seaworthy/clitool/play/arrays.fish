#!/usr/bin/env fish

function salute -a person age
	#echo Hi! $person
	#echo "----"
	#echo "i am" (echo (self_name))
	#echo "- "(echo (self_name))
	#functions_stack
	#echo "i was called by" (caller_name)
	#echo "---- my implementation:"
	functions (self_name)
	echo "----"
	named_arguments (self_name)
end

function complainer --on-variable status
	echo "****"
end

function freak_parser --no-scope-shadowing
	echo "parser"
	set myarg 123
	set argv[4] 123
	echo "!! " $argv[4]
	echo "parser -- $myarg"
	no_parser
end

function no_parser
	set myarg 3456
	echo "no parser -- $myarg"
end

function main -a name something cosa
	echo "set argv[4] 123" | source -
	echo "!!-- " $argv[4]
	named_arguments (self_name)
	set args (named_arguments (self_name))
	count $args
	freak_parser
	echo "main -- $myarg"
	echo "!! " $argv[4]
	#salute $name
	#functions_stack
	self_name
	#caller_name
end

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


#main $argv
salute "pacho"
echo "no main -- $myarg"