

## Adds a new task. It is possible to add a description which is used when
## describing it.
## @param name - the name of the task
## @param description - a brief description for the task
#function task.add -a task description
#  log.debug "adding task $task"
#  if task.exists $task
#    #atn.set "tasks.$task" $description
#  else
#    # TODO make TaskNotFound exception
#    atn.abort "task '$task' was not found"
#  end
#end

## Run a given task name. It raises an exception if the task was not added
## @param task - the name of the task to run
function task.run -a task
  atn.set_rargs $argv
  #task.exists $task; or atn.abort "task '$task' is unknown" #TaskNotKnown

  set task_path (task.resolve_path $task)

  if path.is.dir $task_path
    # this is a group of tasks
    atn.debug "sourcing $task_path/common.fish"
    source "$task_path/common.fish"
    set -l common_task "task.$task.common.run"
    functions -q $common_task ; and eval $common_task
    if test "$rargs"
      set -l subtask $rargs[1]; set -e rargs[1]
      atn.debug "sourcing $task_path/$subtask.fish" 
      source "$task_path/$subtask.fish" 
      eval "task.$task.$subtask.run" $rargs
    else
      atn.debug "running default task"
      set -l default_task "task.$task.default.run"
      functions -q $default_task
      or atn.abort "couldn't find a task to execute, not even $default_task"
      eval $default_task
    end
  else
    # this is a single task
    source $task_path
    eval "task.$task.run" $rargs
  end

end

## Checks whether a task is loaded
## @param task - the name of the task
#function task.exists -a task
#  log.info "-- $task finding"
#  set found_path (task.resolve_path $task)
#  if test "$found_path"
#    log.debug "task '$task' found in $found_path"
#  #else
#  #  atn.abort "task '$task' was not found"
#  #  return 1
#  end
#end

## Resolves a given task name to its filename
## @param task - the name of the task
function task.resolve_path -a task
  #log.info "** $atn_tasks_path resolving **"
  path.resolve "$task.fish" $atn_tasks_path
  or path.resolve "$task" $atn_tasks_path
  or atn.abort "task '$task' was not found"
end
