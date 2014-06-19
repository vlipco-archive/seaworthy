## Raises an exception that can be cautch by catch statement
## @param exception - a string containing the name of the exception
function atn.raise
  set -l exception "$argv[1]"
  shift
  if echo "${FUNCNAME[@]}" | grep -q 'atn.try.do'
    atn.set "atn.Exception.Name" "$exception"
    atn.set "atn.Exception.Msg" "$*"
  else
    atn.abort "Uncaught exception $exception: $*"
  end
end

## Returns the last raised message by atn.raise
function atn.raised_message
  echo (atn.get "atn.Exception.Msg")
end

## Simple implementation of the try statement which exists in other languages
## @param funcname - a string containing the name of the function that can raises an exception
function atn.try.do
  set -l funcname "$argv[1]"
  if is_function? "$funcname"
    shift
    $funcname "$argv"
  end
end

## Catches an exception fired by atn.raise and executes a function
## @param exception - a string containing the exception fired by atn.raise
## @param funcname - a string containing the name of the function to handle exception
function atn.catch
  if [ (atn.get atn.Exception.Name) set   "$argv[1]" ]
    is_function? "$argv[2]" ; and "$argv[2]"
  elif [ -z "$argv[1]" ]
    is_function? "$argv[2]" ; and "$argv[2]"
  end
end

## Executes this command whether an exception is called or not
## @param funcname - a string containing the name of the function to be executed
function atn.finally
  atn.set "atn.Exception.Finally" "$argv[1]"
end

## End a try/catch statement
function atn.try.end
  (atn.get "atn.Exception.Finally")
  atn.unset atn.Exception
end