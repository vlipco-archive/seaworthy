# bitp - bash interpolated template parser
# set  =======================================
#
# heavily inspired by jwerle/mush bitp take any file
# on STDIN and evaluates in bash every expression delimeted by
# double curly braces.
# 
# e.g:
# 
# $ echo "Unit time is: {{date}}" | bitp
# Unit time is: 1402449155
#
# Isn't this the most stupid replacement of ()?
# If used with echo, of course! But this is great for creating
# config files, for example, if you want to create a JSON file
# that has the local hostname as a value to a key. In cases like that
# you could do something like this:
#
# $ cat template.json.bit | bitp > compiled.json

function bit.compile_template -a template_file output_file

	set l_delim "{{"
	set r_delim "}}"
	# the pattern is: get everything between delimiters that doesn't
	# have the right delimeter. This allow multiple interpolations
	# per line to occur
	set exp_pattern $l_delim'[^'$r_delim']*'$r_delim

	log.debug "Compiling $template_file -> $output_file"
	begin
		for line in (cat "$template_file")
			if echo $line | grep -qG $exp_pattern
				set parsed_line $line
				for expression in (echo $line | grep -o $exp_pattern)
					set -l bash_expression (echo $expression | sed "s/$l_delim//")
					set bash_expression (echo $bash_expression | sed "s/$r_delim//")
					set -l result (bash -l -c "$bash_expression")
					set parsed_line (echo $parsed_line | sed "s/$expression/$result/g")
				end
				echo $parsed_line
			else
				echo $line # no expression in the line, leave it as is
			end

		end
	end > $output_file
end