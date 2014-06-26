# this component has been based in progrium/gitreceive
# however it's splitted up in several parts
# for testability purposes

set -g GIT_HOME "/var/cluster/git"

function task.waypoint.common.run
	module.require extras
	module.require consul
end

function _announce -a msg
  log.info "---> $msg"
end

function _indent_output
  sed -u 's/^/     /'
end

function _tcp_docker
	docker -H "tcp://localhost:2375" $argv
end