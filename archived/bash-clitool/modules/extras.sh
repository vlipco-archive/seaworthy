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

function escape_url {
  #http://support.internetconnection.net/CODE_LIBRARY/Perl_URL_Encode_and_Decode.shtml
  cat - | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg'
}

function iso_date {
  date --iso-8601=seconds
}

function _netlog {
  echo "$*" | nc localhost 9090 || true
}