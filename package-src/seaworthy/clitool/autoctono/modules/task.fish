## Run a given task name. It raises an exception if the task was not added
## @param task - the name of the task to run
function task.run -a task
  atn.debug "running task $task"
  atn.set_rargs $argv
  #task.exists $task; or atn.abort "task '$task' is unknown" #TaskNotKnown

  set task_path (task.resolve_path $task)

  if path.is.dir $task_path
    # this is a group of tasks
    if test -e "$task_path/common.fish"
      atn.debug "sourcing $task_path/common.fish"
      source "$task_path/common.fish" ; or exit $status
      set -l common_task "task.$task.common.run"
      functions -q $common_task ; and eval $common_task
    else
      atn.debug "Common task not found, ignoring"
    end
    if test "$rargs"
      set -l subtask $rargs[1]; set -e rargs[1]
      atn.debug "sourcing $task_path/$subtask.fish" 
      source "$task_path/$subtask.fish"  ; or exit $status
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
    source $task_path ; or exit $status
    eval "task.$task.run" $rargs
  end

end

## Resolves a given task name to its filename
## @param task - the name of the task
function task.resolve_path -a task
  #log.info "** $atn_tasks_path resolving **"
  path.resolve "$task.fish" $atn_tasks_path
  or path.resolve "$task" $atn_tasks_path
  or atn.abort "task '$task' was not found"
end
