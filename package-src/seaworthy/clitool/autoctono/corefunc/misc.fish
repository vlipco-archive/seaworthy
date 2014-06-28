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

function atn.indent
  cat - | sed 's/^/        /'
end

function atn.done
	log.title $argv
	exit 0
end

function atn.set
  set atn_registry $atn_registry "$argv[1]=$argv[2]"
end

## Gets a globally scoped variable
## @param varname - the name of the variable
function atn.get
  for item in $atn_registry
  	if echo $item | grep -qG $argv[1]
  		echo $item | awk -F'=' '{print $2}'
  		return 0
  	end
  end
  return 1
end

# todo add flag to skip printing
function atn.debug
	if set -q atn_debug_messages
    echo.cyan "|d| $argv" 1>&2
  end
end

## Sets a globally scoped variable using registry Pattern
## @param varname - the name of the variable
## @param varvalue - the value for the variable



## Returns whether a variable is set or not
## @param varname - the name of the variable
#function atn.is_set?
#  key_exists "$argv[1]" _atn_registry
#  return $status
#end

## Unset a variable and all the ones that follow its name.
## For instance:
##   $ atn.unset atn.Test
## It would unset atn.Test, atn.Testing, atn.Test.Something and so on
## @param varbeginning - the beginning of the varnames to be unsetted
#function atn.unset
#  for key in "${!_atn_registry[@]}"
#    echo "$key" | grep -q "^$argv[1]"
#    [ $status -eq 0 ] ; and unset _atn_registry["$key"]
#  end
#end
