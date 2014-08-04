function task.harbor.common.run
	module.require extras
	module.require consul
	module.require docker
	module.require containers
end

#function _tcp_docker
#	docker -H "tcp://localhost:2375" $argv
#end

function _apps_in_role
	consul.kv.ls "apps/$argv[1]" | awk -F'/' '{print $1}' | sort -u
end

function _container_name
	docker.tcp inspect --format "{{.Name}}" "$argv[1]" | sed 's|^/||'
end
