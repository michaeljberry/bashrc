#!/bin/bash

HOME_DIR="/c/Users/Michael Berry/bashrc"
BASHFILE=".bashrc"
export XDEBUG_CONFIG="idekey=VSCODE"

if [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Loading MAC specific scripts"
	source "${HOME_DIR}"/functions_mac.sh
	BASHFILE=".bash_profile"
fi

echo "Loading Git aliases..."
source "${HOME_DIR}"/aliases_git.sh

echo "Loading Docker aliases..."
source "${HOME_DIR}"/aliases_docker.sh

echo "Loading general aliases..."
source "${HOME_DIR}"/aliases.sh

echo "Loading random aliases..."
source "${HOME_DIR}"/random.sh
