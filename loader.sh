#!/bin/bash

HOME_DIR="/Users/mberry/bashrc"

echo "Loading Git aliases..."
source ${HOME_DIR}/aliases_git.sh

echo "Loading Docker aliases..."
source ${HOME_DIR}/aliases_docker.sh

echo "Loading general aliases..."
source ${HOME_DIR}/aliases.sh

echo "Loading random aliases..."
source ${HOME_DIR}/random.sh

if [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Loading MAC specific scripts"
	source ${HOME_DIR}/functions_mac.sh
fi
