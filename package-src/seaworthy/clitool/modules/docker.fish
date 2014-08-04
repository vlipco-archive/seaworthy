function docker.tcp
	docker -H "tcp://localhost:2375" $argv
end

function docker.login
	docker.tcp login -e (docker.registry_email) \
		-p (swrth consul kv get swrth/registry/password) \
		-u (docker.registry_username) (swrth consul kv get swrth/registry/server)
end

function docker.registry_prefix
	if not test (docker.registry_namespace)
		echo "ERROR: swrth/registry/namespace isn't defined in Consul's KV"
		exit 1
	end
	if test (docker.registry_server)
		echo (docker.registry_server)"/"(docker.registry_namespace)
	else
		echo (docker.registry_namespace)
	end
end

function docker.registry_username
	swrth consul kv get swrth/registry/username
end

function docker.registry_namespace
	swrth consul kv get swrth/registry/namespace
end

function docker.registry_server
	swrth consul kv get swrth/registry/server
end

function docker.registry_email
	swrth consul kv get swrth/registry/email
end
