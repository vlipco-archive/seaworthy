

## Adds a new task. It is possible to add a description which is used when
## describing it.
## @param name - the name of the task
## @param description - a brief description for the task
function atn.task.add
#  echo "---> adding task $argv[1]"
  if atn.task.exists $argv[1]
    #echo "---> found task $argv[1]"
    atn.set "atn.tasks.$argv[1]" "$argv[2]"
  else
    # TODO make TaskNotFound exception
    atn.abort "Task '$argv[1]' was not found"
  end
end

## Run a given task name. It raises an exception if the task was not added
## @param task - the name of the task to run
function atn.task.run

  set -l task $argv[1]
  set -e argv[1]

  if atn.task.exists "$task"
    set -l task_path (atn.task.resolve_path $task)
    if atn.path.is_dir "$task_path"
      # this is a group of tasks
      source "$task_path/common.fish"
      eval "task.$task.common.run"
      if set -q argv[1]
        set -l subtask $argv[1]
        set -e argv[1]
        #echo "---> sourcing $task_path/$subtask.fish" 
        source "$task_path/$subtask.fish" 
        eval "task.$task.$subtask.run" $argv
      else
        #echo "---> running default task"
        eval "task.$task.default.run"
      end
    else
      # this is a single task
      source "$task_path"
      eval "task.$task.run" $argv
    end
  else
    atn.abort "Task '$task' is unknown" #TaskNotKnown
  end
end

## Checks whether a task is loaded
## @param task - the name of the task
function atn.task.exists
  set -l found_path (atn.task.resolve_path "$argv[1]")
  #echo "---> task $argv[1] found in $found_path"
  test -n "$found_path" ; return $status
end

## Resolves a given task name to its filename
## @param task - the name of the task
function atn.task.resolve_path
  atn.path.resolve "$argv[1].fish" $atn_tasks_path
  or atn.path.resolve "$argv[1]" $atn_tasks_path
end
