function task.consul.common.run
	atn.module.require extras
	atn.module.require consul
end

function task.consul.default.run
	atn.abort "no command was given to consul subcmd"
end