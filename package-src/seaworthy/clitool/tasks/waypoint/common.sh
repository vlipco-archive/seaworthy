# this component has been based in progrium/gitreceive
# however it's splitted up in several parts
# for testability purposes

GIT_HOME="/var/cluster/git"

function btask.waypoint.common.run () {
	b.module.require extras
}

function _netlog {
	echo "$*" | nc localhost 9090 || true
}