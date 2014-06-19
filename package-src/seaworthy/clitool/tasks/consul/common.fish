function task.consul.common.run
	atn.module.require extras
	atn.module.require consul
end

function task.consul.default.run
	echo "no command was given"
end