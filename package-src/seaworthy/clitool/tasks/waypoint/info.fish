function task.waypoint.info.run
	module.require containers
	echo "Unassigned containers:"
	ctr.available
end
