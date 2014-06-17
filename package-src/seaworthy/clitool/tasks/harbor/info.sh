function btask.harbor.info.run () {
	#_local_count_of
	#_max_count_of
	_generate_info
}

function _generate_info {
	role="external"
	echo "Role: $role"
	echo "Max. instances per app in role:"
	for app in $(_apps_in_role "$role"); do
		echo "  - $app: $(_max_count_of $app)"
	done
	echo "Currently owned containers:"
	_my_offers | sed 's/^/  - /'
	echo "Total harbors in role: $(_matching_harbors_count)"
}
