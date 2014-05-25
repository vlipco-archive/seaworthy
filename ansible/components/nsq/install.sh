#!/bin/bash
set -eo pipefail

version="0.2.28"
sha256sum="25899925c7294002f3b2b9dd037f0b2777a5efe28122379281cb96e9883e79c3"

target="$1"

pkg="nsq-${version}.linux-amd64.go1.2.1"
pkg_filename="$pkg.tar.gz"

function verify-checksum() {
	if sha256sum $1 | grep -G "$2" &> /dev/null; then
		echo "Checksum verification passed"
	else
		echo "Checksum error"
		exit 1
	fi
}

# check the version
if [[ -e "/usr/local/bin/nsqd" ]]; then
	if /usr/local/bin/nsqd --version | grep -G "$version" ; then
		echo "Skipping install, nsq $version already present"
		exit 0
	fi
fi

echo "Removing previous version if present"
rm -rf $target || :

echo "Installing nsq $version to $target"
mkdir -p $target

cd /tmp
cd $(mktemp -d nsq.dl.XXXX)

echo "Downloading package"
wget -q "https://s3.amazonaws.com/bitly-downloads/nsq/$pkg_filename"
verify-checksum $pkg_filename $sha256sum

echo "Expanding archive"
tar xf $pkg_filename

mv $pkg/bin/* $target
for file in $(ls $target -1); do
	echo "Linking $file"
	rm /usr/local/bin/$file || :
	ln -s $target/$file /usr/local/bin/$file
done
