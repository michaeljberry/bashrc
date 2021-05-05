#!/bin/bash

HOME_DIR=""

set -a
export $(cat ~/bashrc/.env 2>/dev/null | grep -v '^#' | xargs)
# source ./.env
# export $(cut -d= -f1 .env)
set +a
echo "$HOME_DIR"

BASHFILE=".bashrc"

if [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Loading MAC specific scripts"
	source "${HOME_DIR}"/functions_mac.sh
	BASHFILE=".bash_profile"
fi

echo "Loading Git aliases..."
source "${HOME_DIR}"/aliases_git.sh

echo "Loading Git functions..."
source "${HOME_DIR}"/functions_git.sh

echo "Loading Docker aliases..."
source "${HOME_DIR}"/aliases_docker.sh

echo "Loading Docker functions..."
source "${HOME_DIR}"/functions_docker.sh

echo "Loading general aliases..."
source "${HOME_DIR}"/aliases.sh

echo "Loading random aliases..."
source "${HOME_DIR}"/random.sh
