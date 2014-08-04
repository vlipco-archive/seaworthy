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

#function _indent_output
#  sed -u 's/^/     /'
#end

function _distribute -a ctr_filter
	module.require containers
	#TODO disable role hardcode
	set harbors (consul.api.raw_get "catalog/service/harbor?tag=external" | jq -r '.[] | .Node')

	set harbors_count (count $harbors)

	#echo "Finding unsng $ctr_filter"

	if [ -z (_next_available $ctr_filter) ]
		log.info "No unassigned containers matching $ctr_filter were found"
		exit 0
	else
		log.info "Distributing $app containers"
	end

	log.info "Distributing containers between $harbors_count harbor(s)"

	while not [ -z (_next_available $ctr_filter) ]
		set cycle_harbor $harbors[1]
		set ctr (_next_available)
		log.info "Assigning $ctr to $cycle_harbor"
		consul.kv.set "containers/external/$ctr/owner" $cycle_harbor
		if [ $harbors_count -gt 1 ]
			# rotate the array
			set harbors $harbors[2..-1]
			set $harbors[$harbors_count] $cycle_harbor
		end
	end

	for ctr in (ctr.available $filter)
		log.info "Assigning $ctr to -"
	end

	#breakpoint
	# todo handle death node ownership
end

function _next_available -a ctr_filter
	ctr.available $filter | head -n1
end