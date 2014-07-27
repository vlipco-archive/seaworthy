function task.harbor.clienv.run -a app
	# use echo for line break at the end
	echo (_docker_env $app)
end