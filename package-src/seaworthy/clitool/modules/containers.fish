###
### Listing commmands
###

function ctr.available -a app
	set ctr_list (ctr.all)
	test $app; and set ctr_list (echo $ctr_list|grep $app)
	for ctr in $ctr_list
		if [ (consul.kv.get "containers/external/$ctr/owner") = "null" ]
			echo $ctr
		end
	end
end

# list of items in the format app.n, e.g: rubyapp.2
function ctr.all
	# all container will have at least an owner field even if empty
	consul.kv.ls containers/external | grep "owner" | awk -F'/' '{print $1}'
end

function ctr.mine
	for ctr in (ctr.all)
		if [ (consul.kv.get "containers/external/$ctr/owner") = (consul.node_name) ]
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