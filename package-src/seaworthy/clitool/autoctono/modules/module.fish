## Source a module file
## @param module - the name of the module
function module.require
  set -l mpath (module.resolve_path $argv[1])
  atn.debug "Sourcing module $mpath"
  source $mpath
end

## Adds a directory to the end of the module lookup array of directories
## @param dirname - the path for the desired directory
function module.append_lookup_dir
  # TODO raise error is missing argument
  set atn_modules_path $atn_modules_path "$argv[1]"
end

## Adds a directory to the beginning of the module lookup of directories
## @param dirname - the path for the desired directory
function module.prepend_lookup_dir
  # TODO raise error is missing argument
  set atn_modules_path "$argv[1]" $atn_modules_path
end

## Resolves a module name for its path
## @param module - the name of the module
function module.resolve_path
  set -l module_path (path.resolve "$argv[1].fish" $atn_modules_path)
  if [ -n "$module_path" ]
    echo $module_path
  else
    # TODO should be an exception
    atn.abort "Module $argv[1] was not found"
  end
end

## Check whether a given module name exists and is loadable
## @param module - the name of the module
function module.exists
  path.resolve "$argv[1].fish" $atn_modules_path > /dev/null
end
