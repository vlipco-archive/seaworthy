function task.harbor.info.run
	#_local_count_of
	#_max_count_of
	_generate_info
end

function _generate_info
	set role (swrth config harbor.role)
	echo "Role: $role"
	echo "Max. instances per app in role:"
	for app in (_apps_in_role "$role")
		echo "  - $app:" (_max_count_of $app)
	end
	echo "Currently owned containers:"
	ctr.mine | sed 's|^|  - |'
	echo "Total harbors in role:" (_matching_harbors_count)
end

function _matching_harbors_count
	set role (swrth config harbor.role)
	set harbors (consul.api.raw_get "catalog/service/harbor?tag=$role" | jq -r '.[] | .Node')
	count $harbors
end