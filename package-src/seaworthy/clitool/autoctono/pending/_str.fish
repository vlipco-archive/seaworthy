## Replaces a given string to another in a string variable
## @param varname - the name of the variable
## @param search - the string to be searched
## @param replace - the string to be replaced by
function atn.str.replace
  set -l varname (eval echo \$$argv[1]) set search "$argv[2]" replace="$argv[3]"
  echo ${varname/$search/$replace}
end

###
# egt with default? fallback string value
##

## Returns a part of the string. If no length is given,
## it will return until the last char of the string. Negative
## lengths are relative from the back of the string
## @param varname - the name of the variable
## @param offset - the starting offset
## @param length - the length of chars to include
function atn.str.part
  set -l varname (eval echo \$$argv[1])
  if [ $# -eq 3 ]
    echo ${varname: $argv[2]:$argv[3]}
  elif [ $# -eq 2 ]
    echo ${varname: $argv[2]}
  else
    atn.raise InvalidArgumentsException
  end
end

## Trims spaces and tabs from the beginning and at the end string
## @param string - string to be trimmed
function atn.str.trim
  set -l arg "$*"
  [ -z "$arg" ] ; and read arg
  echo "$arg" | sed -E 's/^[ \t]*//g ; s/[ \t]*$//g'
end


## Returns the sinitized argument
## @param arg - Argument to be sinitized
function atn.str.sanitize_arg
  set -l arg "$argv[1]"
  [ -z "$arg" ] ; and read arg
  set arg (echo "$arg" | sed 's/[;&]//g' | sed 's/^ *//g ; s/ *$//g')
  echo "$arg"
end

## Returns the escaped arg (turns -- into \--)
## @param arg - Argument to be escaped
function atn.str.escape_arg
  set -l arg "$argv"
  [ -z "$arg" ] ; and read arg
  if [ "${arg:0:1}" set  = '-' ]
    set arg "\\$arg"
  end
  echo -e "$arg"
end


function atr.str.escape_url
  #http://support.internetconnection.net/CODE_LIBRARY/Perl_URL_Encode_and_Decode.fishtml
  cat - | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($argv[1]))/seg'
end