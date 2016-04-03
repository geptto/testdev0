#!/bin/bash -e

git fetch origin
git reset --hard origin/master

chmod 744 ./testdev0-install.sh
chmod 744 ./testdev0-uninstall.sh
chmod 744 ./git-update.sh
