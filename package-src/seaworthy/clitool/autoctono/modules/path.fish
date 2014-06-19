## Expands a given path to its full path.
## If it has synlinks, it will be converted to the realpath.
## If it is a file, the path will also be expanded to realpath
## It does not return a trailling '/' for directories
## @param path - a path to be expanded
#function atn.path.expand
#  set -l _DIR "$argv[1]" set _FILE ""
#  if [ -f "$argv[1]" ]
#    set _DIR "${1%/*}/"
#    set _FILE "${1/$_DIR/}"
#  end
#  ( (
#    if cd -P "$_DIR" > /dev/null
#      set _REALPATH "$PWD/$_FILE"
#      echo "${_REALPATH%/}"
#    end
#  ) )
#end

## Using a list of search paths, try to find the indicated file
## @param filename - the file or dirname to look for
## @params lookupdir ... - space separated list of directories to look into
function atn.path.resolve
  set -l file "$argv[1]"
  for folder in $argv[2..-1]
    set -l file_path "$folder/$file"
    test -e "$file_path" ; and echo "$file_path" ; and return 0
  end
  return 1
end

## Returns true if the passed path is a directory, false otherwise
## @param path - the path to be checked
function atn.path.is_dir
  test -d "$argv[1]"
end

## Returns true if the passed path is a file, false otherwise
## @param path - the path to be checked
function atn.path.is_file
  test -f "$argv[1]"
end

## Returns whether the path is a file
## @param path - the path to be checked
function atn.path.is_block
  test -b "$argv[1]"
end

## Returns whether the path is readable
## @param path - the path to be checked
function atn.path.is_readable
  test -r "$argv[1]"
end

## Returns whether the path is writable
## @param path - the path to be checked
function atn.path.is_writable
  test -w "$argv[1]"
end
## Returns whether the path is executable
## @param path - the path to be checked
function atn.path.is_executable
  test -x "$argv[1]"
end

## Returns whether the path is older than another path
## @param path - the path to be checked
## @param another_path - the path to be checked against
function atn.path.is_older
  test "$argv[1]" -ot "$argv[2]"
end

## Returns whether the path is newer than another path
## @param path - the path to be checked
## @param another_path - the path to be checked against
function atn.path.is_newer
  test "$argv[1]" -nt "$argv[2]"
end
