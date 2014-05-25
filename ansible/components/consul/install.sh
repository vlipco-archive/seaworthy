#!/bin/bash
set -eo pipefail

version="0.2.1"
sha256sum="0b4a91051c35acd86a8adc89b1c5d53c31cb3260eec88646cc47081729b0dbbf"
ui_sha256sum="3a8b00499002b56f101abecb2df3bd8ae6f417b776d76059aaeb42dded378ba0"
target="$1"

pkg_filename="${version}_linux_amd64.zip"
ui_pkg_filename="${version}_web_ui.zip"

function verify-checksum() {
	if sha256sum $1 | grep -G "$2" &> /dev/null; then
		echo "Checksum verification passed"
	else
		echo "Checksum error"
		exit 1
	fi
}

function install-consul() {
	echo "Removing previous version if present"
	rm -rf $target || :
	rm /usr/local/bin/consul || :

	echo "Installing consul $version to $target"
	mkdir -p $target
	
	cd /tmp
	cd $(mktemp -d consul.dl.XXXX)

	echo "Downloading package"
	wget -q "https://dl.bintray.com/mitchellh/consul/$pkg_filename"
	verify-checksum $pkg_filename $sha256sum

	echo "Expanding package"
	unzip $pkg_filename

	mv consul $target
	ln -s $target/consul /usr/local/bin/consul

	echo "Downloading UI"
	wget "https://dl.bintray.com/mitchellh/consul/$ui_pkg_filename" 
	verify-checksum $ui_pkg_filename $ui_sha256sum
	unzip $ui_pkg_filename
	mv dist $target/ui
}

if [[ -e "/usr/local/bin/consul" ]] ; then
	if /usr/local/bin/consul --version | grep -G "$version" &> /dev/null ; then
		echo "Skipping install, consul $version already present"
		exit 0
	fi
fi

install-consul