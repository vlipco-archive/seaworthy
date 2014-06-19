## Return whether the argument is a valid module
## @param module - the name of the module
#function atn.is_module?
#  module.exists "$argv[1]"
#end

## Checks if a function exists
## @param funcname -- Name of function to be checked
#function atn.is_function?
#  declare -f "$argv[1]" >/dev/null ; and return 0
#  return 1
#end

## Print to the stderr
## @param [text ...] - Text to be printed in stderr
#function atn.echoerr
  #echo -e "$argv" >&2
#end

## Raises an error an exit the code
## @param [msg ...] - Message of the error to be raised
function atn.abort
  log.error "error: $argv"
  exit 2
end

function atn.end
	echo "$argv"
	exit 0
end
