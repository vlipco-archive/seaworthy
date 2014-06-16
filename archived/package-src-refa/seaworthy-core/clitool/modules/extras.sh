function b.resolve_dir_path () {
  local dir_name="$1"
  shift
  while [ -n "$1" ]; do
    local dir_path="$1/$dir_name"
    test -d "$dir_path" && echo -n "$dir_path" && return 0
    shift
  done
  return 1
}

function b.done() {
	echo "$@"
	exit 0
}

function b.path.filename {
  echo "${1##*/}"
}

## Returns whether the path exists
## @param path - the path to be checked
function b.path.exists? () {
  test -e "$1"
}

# todo add extension helper too

# requires rainbow.sh
function b.info {
  echoyellow "$@"
}

function b.error {
  print_e $(echored "$@")
}