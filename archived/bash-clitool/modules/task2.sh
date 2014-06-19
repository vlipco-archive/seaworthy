_BANG_TASK_DIRS=(./tasks "$BANG_PATH/tasks")

b.module.require path

## Adds a new task. It is possible to add a description which is used when
## describing it.
## @param name - the name of the task
## @param description - a brief description for the task
function b.task.add () {
  local task="$1" description="$2"

  if b.task.exists? "$task"; then
    b.set "bang.tasks.$task" "$description"
  else
    b.raise TaskNotFound "Task '$task' was not found"
  fi
}

## Run a given task name. It raises an exception if the task was not added
## @param task - the name of the task to run
function b.task.run () {
  local task="$1"
  shift

  if b.task.exists? "$task"; then
    local task_path="$(b.task.resolve_path $task)"
    if b.path.dir? "$task_path"; then
      # this is a group of tasks
      source "$task_path/common.sh"
      "btask.$task.common.run"
      local subtask="$1"
      shift
      if [ -n "$subtask" ]; then
        source "$task_path/$subtask.sh" 
        "btask.$task.$subtask.run" "$@"
      else
        "btask.$task.default.run" "$@"
      fi
    else
      # this is a single task
      source "$task_path"
      "btask.$task.run" "$@"
    fi
  else
    b.raise TaskNotKnown "Task '$task' is unknown"
  fi
}

## Checks whether a task is loaded
## @param task - the name of the task
function b.task.exists? () {
  b.task.resolve_path "$1" &> /dev/null
}

## Resolves a given task name to its filename
## @param task - the name of the task
function b.task.resolve_path () {
  b.resolve_path "$1" "${_BANG_TASK_DIRS[@]}" \
  || b.resolve_path "$1.sh" "${_BANG_TASK_DIRS[@]}"
}
