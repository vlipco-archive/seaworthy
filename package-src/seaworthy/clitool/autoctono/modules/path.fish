## Expands a given path to its full path.
## If it has synlinks, it will be converted to the realpath.
## If it is a file, the path will also be expanded to realpath
## It does not return a trailling '/' for directories
## @param path - a path to be expanded
#function path.expand
#  set -l _DIR $filepath set _FILE ""
#  if [ -f $filepath ]
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
function path.resolve -a filepath
  atn.set_rargs $argv
  for folder in $rargs
    set -l file_path "$folder/$file"
    test -e "$file_path" ; and echo "$file_path" ; and return 0
  end
  return 1
end

## Returns true if the passed path is a directory, false otherwise
## @param path - the path to be checked
function path.is_dir -a filepath
  test -d $filepath
end

## Returns true if the passed path is a file, false otherwise
## @param path - the path to be checked
function path.is_file -a filepath
  test -f $filepath
end

## Returns whether the path is a file
## @param path - the path to be checked
function path.is_block -a filepath
  test -b $filepath
end

## Returns whether the path is readable
## @param path - the path to be checked
function path.is_readable -a filepath
  test -r $filepath
end

## Returns whether the path is writable
## @param path - the path to be checked
function path.is_writable -a filepath
  test -w $filepath
end
## Returns whether the path is executable
## @param path - the path to be checked
function path.is_executable -a filepath
  test -x $filepath
end

function path.exists -a filepath
  test -e $filepath
end

function path.not_found -a filepath
  not path.exists $filepath
end

## Returns whether the path is older than another path
## @param path - the path to be checked
## @param another_path - the path to be checked against
function path.is_older -a filepath_a filepath_b
  test $filepath_a -ot $filepath_b
end

## Returns whether the path is newer than another path
## @param path - the path to be checked
## @param another_path - the path to be checked against
function path.is_newer -a filepath_a filepath_b
  test $filepath_a -nt $filepath_b
end