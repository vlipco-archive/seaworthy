function btask.init.run {
	echo
	echo "Performing after-install tasks"
	echo

	if [[ ! -e "/etc/resolv.conf.orig" ]]; then
		echo "Saving copy of current resolv.conf to /etc/resolv.conf.orig"
		cat /etc/resolv.conf > /etc/resolv.conf.orig
	fi

	echo "Creating local configuration directories/files and links"

	mkdir -p /usr/local/lib/seaworthy/components
	mkdir -p /var/lib/seaworthy/consul
	mkdir -p /var/lib/seaworthy/events
	mkdir -p /var/lib/seaworthy/checks
	mkdir -p /var/lib/seaworthy/components
	
	if [[ ! -e "/var/checks" ]]; then
		ln -s /var/lib/seaworthy/checks /var/checks
	fi

	echo
	echo "Enabling common components"
	echo

	common_components=(base)
	for component in "${common_components[@]}"; do
		swrth components enable "$component"
		echo
	done

	echo
	echo "Enabling cluster.target"
	echo

	systemctl enable /var/lib/seaworthy/cluster.target

	echo
	echo "Done."
}