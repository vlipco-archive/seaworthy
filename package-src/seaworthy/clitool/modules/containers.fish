###
### Listing commmands
###

function ctr.available -a role_filter
	#set ctr_list (ctr.all | grep "$role_filter/" )
	#test "$role" ; and set ctr_list (echo $ctr_list )
	for ctr in (ctr.all | grep "$role_filter/" )
		set owner (consul.kv.get "containers/$ctr/owner")
		if [ "$owner" = "null" ]
			echo $ctr
		end
	end
end

# list of items in the format role/app.n, e.g: staff/rubyapp.2
function ctr.all
	# all container will have at least an owner field even if empty
	consul.kv.ls "containers" | grep "owner" | sed 's|/owner||'
end

function ctr.mine
	for ctr in (ctr.all)
		if [ (consul.kv.get "containers/$ctr/owner") = (consul.node_name) ]
			echo "$ctr"
		end
	end
end

function ctr.env -a app_ns
	module.require consul
	set namespace "apps/$app_ns/environment"
	begin
		for env_var in (consul.kv.ls $namespace )
			echo '-e "'(echo $env_var | tr a-z A-Z)"="(consul.kv.get "$namespace/$env_var")'"'
		end
	end | tr "\\n" " "
end