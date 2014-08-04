function task.docker.ip.run
	ip addr | awk '/inet/ && /docker0/{sub(/\/.*$/,"",$2); print $2}'
end