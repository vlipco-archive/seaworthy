function task.waypoint.distribute.run -a app
	if [ -z $app ]
		atn.abort "You didn't indicate what application to balance. Use all for all apps."
	end
	
	set ctr_filter $app
	[ $app = "all" ]; and set filter

	_distribute $ctr_filter
end



#function ctr.acquire -a ctr_id
#	consul.kv.set "containers/external/$ctr_id/owner" (hostname)
#end