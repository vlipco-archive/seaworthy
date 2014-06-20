# this component has been based in progrium/gitreceive
# however it's splitted up in several parts
# for testability purposes

set GIT_HOME "/var/cluster/git"

function task.waypoint.common.run
	module.require extras
end

