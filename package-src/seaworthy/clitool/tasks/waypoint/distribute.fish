function task.waypoint.distribute.run -a role app
	if test -z $app; or test -z $role
		atn.abort "Role and application params are required."
	end
	_distribute $role $app
end
