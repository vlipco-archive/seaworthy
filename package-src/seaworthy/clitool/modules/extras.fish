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

function _netlog
  echo "$argv" | nc localhost 9090 ; or true
end

function iso_date
  date --iso-set 8601 seconds
end