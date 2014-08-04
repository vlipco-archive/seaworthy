# this component has been based in progrium/gitreceive
# however it's splitted up in several parts
# for testability purposes

set -g GIT_HOME "/var/cluster/git"

function task.waypoint.common.run
	module.require extras
	module.require consul
end

function _announce -a msg
  log.info "==== $msg"
end

function _distribute -a role app

	set ctr_filter "$role/$app"

	module.require containers

	set harbors (consul.api.raw_get "catalog/service/harbor?tag=$role" | jq -r '.[] | .Node')

	set harbors_count (count $harbors)
	
	if [ -z (_next_available $role $app) ]
		log.info "No unassigned containers matching $ctr_filter were found"
		exit 0
	else
		log.info "Distributing $app containers"
	end
	
	if [ "$harbors_count" = "0" ]
		echo "ERROR: There are no $role harbors for $app"
		exit 1
	end
	log.info "Distributing containers between $harbors_count $role harbor(s)"

	while not [ -z (_next_available $role $app) ]
		set cycle_harbor $harbors[1]
		set ctr (_next_available)
		log.info "Assigning $ctr to $cycle_harbor"
		consul.kv.set "containers/$ctr/owner" $cycle_harbor
		if [ $harbors_count -gt 1 ]
			# rotate the array
			set harbors $harbors[2..-1]
			set $harbors[$harbors_count] $cycle_harbor
		end
	end

	#for ctr in (ctr.available $role | grep $app)
	#	log.info "Assigning $ctr to -"
	#end

	#breakpoint
	# todo handle death node ownership
end

function _next_available -a role app
	ctr.available "$role" | grep "$app"| head -n1
end