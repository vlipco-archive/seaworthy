function task.consul.leader.run
	module.require consul
	consul.leader
	exit $status
end