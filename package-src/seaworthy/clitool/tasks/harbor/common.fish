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

function _docker_env -a app
	module.require consul
	set role (swrth config harbor.role)
	set namespace "apps/$role/$app/environment"
	begin
		for env_var in (consul.kv.ls $namespace )
			echo '-e "'(echo $env_var | tr a-z A-Z)"="(consul.kv.get "$namespace/$env_var")'"'
		end
	end | tr "\\n" " "
end