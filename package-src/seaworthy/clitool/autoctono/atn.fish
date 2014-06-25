# this is a fish port of atnsh with some additions 
# that I wanted to have! Thanks @bellthoven

set atn_src (dirname (status --current-filename))
set bundle_src (readlink -f "$atn_src/..")

# define it to assign the scope
set atn_registry

set atn_modules_path "$bundle_src/modules" "$atn_src/modules"
set atn_tasks_path "$bundle_src/tasks"

# bootstrap sourcing
source "$atn_src/corefunc/arguments.fish"; or exit $status
source "$atn_src/corefunc/misc.fish"; or exit $status

source "$atn_src/modules/log.fish"; or exit $status
source "$atn_src/modules/path.fish"; or exit $status
source "$atn_src/modules/module.fish"; or exit $status
source "$atn_src/modules/task.fish"; or exit $status

# from here require works
#module.require log
#exit 1
#module.require task
