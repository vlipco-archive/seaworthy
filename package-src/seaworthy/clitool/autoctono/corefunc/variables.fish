## Sets a globally scoped variable using registry Pattern
## @param varname - the name of the variable
## @param varvalue - the value for the variable
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