###
### Listing commmands
###

function ctr.available -a app
	set ctr_list (ctr.all)
	test $app; and set ctr_list (echo $ctr_list|grep $app)
	for ctr in $ctr_list
		if [ -z (consul.kv.get "containers/external/$ctr/owner") ]
			echo $ctr
		end
	end
end

# list of items in the format app.n, e.g: rubyapp.2
function ctr.all
	consul.kv.ls containers/external | grep "state" | awk -F'/' '{print $1}'
end

function ctr.mine
	for ctr in (ctr.all)
		if [ (consul.kv.get "containers/external/$ctr/owner") = (consul.node_name) ]
			echo "$ctr"
		end
	end
end