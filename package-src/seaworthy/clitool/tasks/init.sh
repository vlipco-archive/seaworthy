function btask.init.run {
	if [[ ! -e "/etc/resolv.conf.orig" ]]; then
		echo "Saving copy of current resolv.conf to /etc/resolv.conf.orig"
		cat /etc/resolv.conf > /etc/resolv.conf.orig
	fi

	echo "Creating local configuration directories/files and links"

	mkdir -p /usr/local/lib/seaworthy/components
	
	mkdir -p /var/cluster/active/consul
	mkdir -p /var/cluster/active/events
	mkdir -p /var/cluster/active/checks
	mkdir -p /var/cluster/active/components
	
	echo
	echo "Enabling base component"
	echo
	
	swrth components enable base


	echo
	echo "Done."
}