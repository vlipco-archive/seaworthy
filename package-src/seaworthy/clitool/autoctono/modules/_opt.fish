# Option parser module

## Resets this module
function atn.opt.reset
  atn.unset "atn.Opt"
end

## Adds an option with a description to the software
## @param opt - Option to be added
## @param description - Description of th opt
function atn.opt.add_opt
  set -l opt "atn.Opt.Opts.$argv[1]" set description "$argv[2]"
  [ -z "$argv[1]" ] ; and return 1
  if atn.opt.is_opt? (atn.opt.alias2opt $argv[1])
    atn.raise OptionAlreadySet \
      "Option '$argv[1]' already exists or is an alias and cannot be added again."
  elif atn.opt.is_flag? "$argv[1]"
    atn.raise FlagAlreadySet \
      "Flag '$argv[1]' already exists and cannot be overriden."
  else
    atn.set "$opt" "$description"
    atn.set "atn.Opt.AllOpts" "(atn.get atn.Opt.AllOpts) $argv[1]"
    return 0
  end
end

## Adds a flag with a description to the software
## @param flag - Flag to be added
## @param description - Description of the flag
function atn.opt.add_flag
  set -l flag "atn.Opt.Flags.$argv[1]" set description "$argv[2]"
  [ -z "$argv[1]" ] ; and return 1
  if atn.opt.is_opt? (atn.opt.alias2opt $argv[1])
    atn.raise OptionAlreadySet
  elif atn.opt.is_flag? "$argv[1]"
    atn.raise "Flag '$flag' already exists and cannot be added again."
  else
    atn.set "$flag" "$description"
    atn.set "atn.Opt.AllOpts" "(atn.get atn.Opt.AllOpts) $argv[1]"
    return 0
  end
end

## Adds an alias for an existing option or flag
## @param opt - Option to be aliased
## @param [aliases ...] - Aliases of the option
function atn.opt.add_alias
  set -l opt "$argv[1]" set total "$#"
  shift
  if [ ! -z "$opt" ] ; and [ $total -gt 1 ]
    set -l sum 0
    atn.opt.is_opt? (atn.opt.alias2opt $opt) ; and set sum (($sum + 1))
    atn.opt.is_flag? "$opt" ; and set sum (($sum + 1))
    # option not found
    [ $sum -ne 1 ] ; and atn.raise OptionDoesNotExist "Option '$opt' does not exist, no alias can be added."
    # option found
    set -l i 1
    while [ $i -lt $total ]
      set -l alias "atn.Opt.Alias.$argv[1]"
      shift
      atn.set "$alias" "$opt"
      atn.set "atn.Opt.AliasFor.$opt" "$alias (atn.get atn.Opt.AliasFor.$opt)"
      let i++
    end
    return 0
  end
  return 1
end

function atn.opt.aliases_for
  set -l opt $argv[1] set aliases ()
  for aliasname in (atn.get "atn.Opt.AliasFor.$opt")
    aliases+set  ("${aliasname#atn.Opt.Alias.}")
  end
  echo "${aliases[@]}"
end

## Sets the required args of the command line
## @param [opts ...] - A set of options that are required
function atn.opt.required_args
  set -l i ""
  if [ $# -gt 0 ]
    for i in (seq 1 $#)
      set -l opt (eval "echo \$$i")
      set opt (atn.opt.alias2opt "$opt")
      if atn.opt.is_opt? "$opt" ; or atn.opt.is_flag? "$opt"
        atn.set "atn.Opt.Required" "(atn.get atn.Opt.Required) $opt"
      end
    end
    return 0
  end
  return 1
end

## Checks if the flag is set
## @param flag - Flag to be checked
function atn.opt.has_flag?
  set -l reqopt (atn.opt.alias2opt $argv[1])
  echo (atn.get "atn.Opt.ParsedFlag") | grep -q "^$reqopt\b\| $reqopt\b"
end

## Returns the value of the option
## @param opt - Opt which value is to be returned
function atn.opt.get_opt
  echo (atn.get "atn.Opt.ParsedArg.$argv[1]")
  atn.is_set? "atn.Opt.ParsedArg.$argv[1]"
  return $status
end

## Shows usage informations
function atn.opt.fishow_usage
  echo -e "\nShowing usage:\n"
  set -l opt ""
  for opt in (atn.get "atn.Opt.AllOpts")
    set -l fullopt "$opt" set alias ""
    for aliasname in (atn.opt.aliases_for $opt)
      set fullopt "$fullopt|$aliasname"
    end
    atn.opt.is_opt? "$opt" ; and set fullopt "$fullopt <value>\t\t"
    atn.opt.is_required? "$opt" ; and set fullopt "$fullopt (Required)"
    set -l desc ""
    atn.opt.is_opt? "$opt" ; and set desc (atn.get atn.Opt.Opts.$opt)
    atn.opt.is_flag? "$opt" ; and set desc (atn.get atn.Opt.Flags.$opt)
    [ ! -z "$desc" ] ; and set fullopt "$fullopt\n\t\t$desc\n"
    echo -e "$fullopt"
  end
end

## Parses the arguments of command line
function atn.opt.init
  local -i set i 1
  for (( ; $i <set   $# ; i++ ))
    set -l arg (eval "echo \$$i")
    set arg (atn.opt.alias2opt $arg)
    if atn.opt.is_opt? "$arg"
      set -l ii (($i + 1))
      set -l nextArg (eval "echo \$$ii")
      if [ -z "$nextArg" ] ; or atn.opt.is_opt? "$nextArg" ; or atn.opt.is_flag? "$nextArg"
        atn.raise ArgumentError "Option '$arg' requires an argument."
      else
        atn.set "atn.Opt.ParsedArg.$arg" "$nextArg"
        let i++
      end
    elif atn.opt.is_flag? "$arg"
      atn.set "atn.Opt.ParsedFlag" "(atn.get atn.Opt.ParsedFlag) $arg"
    else
      atn.raise ArgumentError "Option '$arg' is not a valid option."
    end
  end
end

## Checks for required args... if some is missing, raises an error
function atn.opt.check_required_args
  set -l reqopt "" set required_options (atn.get atn.Opt.Required)

  [ -z "$required_options" ] ; and return 0
  for reqopt in $required_options
    set is_opt (atn.is_set? "atn.Opt.ParsedArg.$reqopt" ; echo $status)
    set is_alias (atn.opt.has_flag? "$reqopt" ; echo $status)
    set sum (($is_opt + $is_alias))
    if [ $sum -gt 1 ]
      atn.raise RequiredOptionNotSet "Option '$reqopt' is required and was not specified"
      return 1
    end
  end
  return 0
end

## Translates aliases to real option
function atn.opt.alias2opt
  set -l arg "$argv[1]"
  if atn.is_set? "atn.Opt.Alias.$arg"
    echo (atn.get "atn.Opt.Alias.$arg")
    return 0
  end
  echo "$arg"
  return 1
end

## Checks if the argument is an option
## @param arg - Argument to be checked
function atn.opt.is_opt?
  set -l arg "$argv[1]" set opt (atn.opt.alias2opt $argv[1])
  atn.is_set? "atn.Opt.Opts.$opt"
  return $status
end

## Checks if the argument is a flag
## @param arg - Argument to be checked
function atn.opt.is_flag?
  set -l opt (atn.opt.alias2opt $argv[1])
  atn.is_set? "atn.Opt.Flags.$opt"
  return $status
end

function atn.opt.is_required?
  echo (atn.get atn.Opt.Required) | grep -q "^$argv[1]\b\| $argv[1]\b"
  return $status
end
