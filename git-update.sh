#!/bin/bash -e

git fetch origin
git reset --hard origin/master

chmod 744 ./testdev0-setup.sh
chmod 744 ./testdev0-revert.sh
chmod 744 ./git-update.sh
