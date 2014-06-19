# this is a fish port of atnsh with some additions 
# that I wanted to have! Thanks @bellthoven

set atn_src (dirname (status --current-filename))
set bundle_src (readlink -f "$atn_src/..")

# define it to assign the scope
set atn_registry

set atn_modules_path "$bundle_src/modules" "$atn_src/modules"
set atn_tasks_path "$bundle_src/tasks"

# bootstrap sourcing
source "$atn_src/modules/path.fish"
source "$atn_src/modules/module.fish"

# from here require works
atn.module.require misc
atn.module.require variables
atn.module.require log
atn.module.require task
