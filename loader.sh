#!/bin/bash

HOME_DIR=""

set -a
export $(cat ~/bashrc/.env 2>/dev/null | grep -v '^#' | xargs)
# source ./.env
# export $(cut -d= -f1 .env)
set +a
echo "$HOME_DIR"

BASHFILE="bashrc/bashrc"
export XDEBUG_CONFIG="idekey=VSCODE"

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Loading MAC specific scripts"
  source "${HOME_DIR}"/functions_mac.sh
  BASHFILE=".bash_profile"
fi

echo "Loading bash aliases and functions"
source "${HOME_DIR}"/"$BASHFILE"

echo "Loading Git aliases..."
source "${HOME_DIR}"/aliases_git.sh

echo "Loading Git functions..."
source "${HOME_DIR}"/functions_git.sh

echo "Loading Docker aliases..."
source "${HOME_DIR}"/aliases_docker.sh

echo "Loading Docker functions..."
source "${HOME_DIR}"/functions_docker.sh

echo "Loading Laravel aliases..."
source "${HOME_DIR}"/aliases_laravel.sh

# echo "Loading Laravel functions..."
# source "${HOME_DIR}"/functions_laravel.sh

echo "Loading Laravel Package functions..."
source "${HOME_DIR}"/functions_laravel_package.sh

echo "Loading general aliases..."
source "${HOME_DIR}"/aliases.sh

echo "Loading random aliases..."
source "${HOME_DIR}"/random.sh
