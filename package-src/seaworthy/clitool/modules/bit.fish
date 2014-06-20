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

function bit.compile_string
	set -l l_delim "{{"
	set -l r_delim "}}"
	# the pattern is: get everything between delimiters that doesn't
	# have the right delimeter. This allow multiple interpolations
	# per line to occur
	set -l pattern "${l_delim}[^${r_delim}]*${r_delim}"

	# read each line, the OR is in case the file's missing
	# a new line in the end. more info: http://bit.ly/1xFVHKU
	# set IFS '' preserves whitespace when reading the lines
	while read line #; or [ -n "$line" ]

		if echo "$line" | grep -G "$pattern" -q
			# this line has expressions in it
			set -l parsed_line "$line"

			while read expression
				# remove delimiters from the expression
				set -l bash_expression ${expression/$l_delim/}
				set bash_expression ${bash_expression/$r_delim/}

				# execute the expression with bash as subprocess
				# TODO raise exceptions on failure
				set -l result (bash -l -c "$bash_expression")
				set parsed_line ${parsed_line/$expression/$result}
			end <<< (echo "$line" | grep -o "$pattern")

			echo "$parsed_line"
		else
			# no expression in the line, leave it as is
			echo "$line"
		end
	end
end

function bit.compile_template -a template_file output_file
	cat "$template_file" | bit.compile_string > "$output_file"
end