## Checks if the element is in the given array name
## @param element - element to be searched in array
## @param array - name of the array variable to search in
function in_array?
  set -l element "$argv[1]" set array "$argv[2]"
  test -z "$element" -o -z "$array" ; and return 1
  # Sanitize!
  set array (sanitize_arg "$array")
  set -l values (eval echo \"\${$array[@]}\")
  set element (escape_arg "$element")
  echo "$values" | grep -wq "$element"
  return $status
end

## Checks if the given key exists in the given array name
## @param key - key to check
## @param array - name of the array variable to be checked
function key_exists
  set -l key "$argv[1]" set array "$argv[2]"
  test -z "$key" -o -z "$array" ; and return 1
  set array (sanitize_arg "$array")
  echo (eval echo \"\${!$array[@]}\")" | grep -wq "(escape_arg $key)
  return $status
end



## Check if a given dependency is executable.
##
## In case it is not raises `DependencyNotMetException`.
##
## @param dependency - a string containing the name or a path of the command to be checked
#function atn.depends_on -a dependency
#  if ! which -s "$dependency"
#    atn.raise DependencyNotMetException "This script depends on '$dependency', but it is not #executable. Check your \$PATH definition or install it before running."
#    return 1
#  end
#end

#function atn.resolve_dir_path
#  set -l dir_name "$argv[1]"
#  shift
#  while [ -n "$argv[1]" ]
#    set -l dir_path "$argv[1]/$dir_name"
#    test -d "$dir_path" ; and echo -n "$dir_path" ; and return 0
#    shift
#  end
#  return 1
#end

## Returns whether the path exists
## @param path - the path to be checked
function path.exists
  test -e $argv[1]
end

# todo add extension helper too
