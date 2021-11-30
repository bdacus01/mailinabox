#!/bin/bash
#########################################################
# This script is intended to be run like this:
#
#   curl https://mailinabox.email/setup.sh | sudo bash
#
#########################################################

# Check that we are running on Debian 10 or higher.
if [ "$(lsb_release -i)" = "Debian" ] && [ "$(lsb_release -r)" -gt "9" ]; then
	echo "Mail-in-a-Box only supports being installed on Debian, sorry. You are running:"
	echo
	lsb_release -d | sed 's/.*:\s*//'
	echo
else
	echo "This script must be run on a system running Debian 10 or higher."
	exit 1
fi

# Are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root. Did you leave out sudo?"
	exit 1
fi

# Clone the Mail-in-a-Box repository if it doesn't exist.
if [ ! -d $HOME/mailinabox ]; then
	if [ ! -f /usr/bin/git ]; then
		echo Installing git . . .
		apt-get -q -q update
		DEBIAN_FRONTEND=noninteractive apt-get -q -q install -y git </dev/null
		echo
	fi

	echo Downloading Mail-in-a-Box. . .
	git clone \
		--depth 1 \
		https://github.com/bdacus01/mailinabox \
		$HOME/mailinabox \
		</dev/null 2>/dev/null

	echo
fi

# Change directory to it.
cd $HOME/mailinabox

# Update it.
if [ "$TAG" != $(git describe) ]; then
	echo Updating Mail-in-a-Box to . . .
	git fetch --depth 1 --force --prune origin
	if ! git checkout -q $TAG; then
		echo "Update failed. Did you modify something in $(pwd)?"
		exit 1
	fi
	echo
fi

# Start setup script.
setup/start.sh
