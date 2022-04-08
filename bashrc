#!/bin/bash

###
# Navigate to root dev folder - optionally navigate to project
#
# @param folder
###
function dev() {
    folder=$1
    printf "Navigating to Dev root folder... \n"

    cd ~ || return
    cd "$rootdevfolder" || return

    if [ -n "$folder" ]; then
        navigateToProject "$project"
    fi
}

export XDEBUG_CONFIG="idekey=VSCODE"

###
# Open project in Visual Studio Code and navigate to project folder
#
# @param project
###
openEditor() {
  project=$1

    dev ""

    if [ -d "$project" ]; then
        printf "Opening %s project in VSC \n" "$project"
        code "$project"

    cd "$project" || exit
  fi
}

###
# Return inputType, default is "folder"
#
# @param inputType
#
# @return inputType
#
# @tests
#
# inputType
# Result: folder
#
# inputType folder
# Result: folder
#
# inputType project
# Result: project
###

inputType() {
  inputType=$1

  if [ -z "$inputType" ]; then
    inputType="folder"
  fi

  echo "$inputType"
}

###
# Return if folder should be created, default is "false"
#
# @param boolean shouldFolderBeCreated
#
# @return shouldFolderBeCreated
#
# @tests
#
# shouldFolderBeCreated
# Result: false
#
# shouldFolderBeCreated true
# Result: true
###

shouldFolderBeCreated() {
  shouldFolderBeCreated=$1

  if [ -z "$shouldFolderBeCreated" ]; then
    shouldFolderBeCreated=false
  fi

  echo "$shouldFolderBeCreated"
}

###
# Create folder
#
# @param folder
#
# @return folder
#
# @tests
#
# createFolder
# Result:
#
# createFolder blah
# Result: Blah
###

createFolder() {
  folder=$1

  folder="$(inputIsSet "folder" "$folder")"
  mkdir "$folder"

  echo "$folder"
}

###
# Create folder if not already exists
#
# @param folder
# @param shouldFolderBeCreated
#
# @return folder
#
# @tests
#
# createFolderIfNeeded
# Result:
#
# createFolderIfNeeded blah
# Result:
#
# createFolderIfNeeded blah true
# Result: blah
###

createFolderIfNeeded() {
  folder=$1
  shouldFolderBeCreated=$2

  shouldFolderBeCreated="$(shouldFolderBeCreated "$shouldFolderBeCreated")"

  if [ "$shouldFolderBeCreated" = "true" ]; then
    folder="$(createFolder "$folder")"
    echo "$folder"
  fi
}

###
# Checks if folder is a valid folder
#
# @param folder
# @param folderType
#
# @return folder
#
# @tests
#
# validFolderName
# Result: Please type a valid folder name:
#
# validFolderName blah
# Result: Please type a vlid folder name:
#
# validFolderName michaeljberry
# Result: michaeljberry
###

validFolderName() {
  folder=$1
  folderType=$2

  folderType="$(inputType "$folderType")"

    while [ ! -d "$folder" ]; do
        read -r -p "Please type a valid $folderType name: " folder
    done

  echo "$folder"
}

###
# Check if input is set, prompt if not
#
# @param inputType
# @param input
#
# @return input
#
# @tests
#
# inputIsSet
# Result: Please type a folder name:
#
# inputIsSet blah
# Result: blah
#
# inputIsSet blah project
# Result: blah
###

inputIsSet() {
  inputType=$1
  input=$2

  inputType="$(inputType "$inputType")"

  while [ -z "$input" ]; do

        read -r -p "Please type a valid $inputType name: " input
    done

  echo "$input"
}

###
# Check if folder already exists
#
# @param folder
# @param folderType
#
# @return folder
#
# @tests
#
# folderExists
# Result: Please type a valid folder name:
#
# folderExists blah
# Result: false
#
# folderExists blah project
# Result: false
#
# folderExists app
# Result: true
#
# folderExists app project
# Result: true
###

folderExists() {
  folder=$1
  folderType=$2

  folderType="$(inputType "$folderType")"
  folder="$(validFolderName "$folder" "$folderType")"

  echo "$folder"
}

###
# Navigate to folder and create it if necessary
#
# @param folder
# @param shouldFolderBeCreated
# @param folderType
#
# @tests
#
# navigateToFolder
# Result: Please type a valid folder name:
#
# navigateToFolder blah
# Result:
#
# navigateToFolder blah true
# Result: blah
# Result: /blah
#
# navigateToFolder blah false
# Result:
#
# navigateToFolder app
# Result: app
# Result: /app
#
# navigateToFolder app true
# Result: app
# Result: /app
#
# navigateToFolder app false
# Result: app
# Result: /app
###

navigateToFolder() {
  folder=$1
  shouldFolderBeCreated=$2
  folderType=$3

    folderType="$(inputType "$folderType")"
    # createdFolder="$(createFolderIfNeeded "$folder" "$shouldFolderBeCreated")"
    folder="$(folderExists "$folder" "$folderType")"

    if [ -n "$folder" ]; then
        cd "$folder" || return
    fi
}

alias reclaimdocker='docker run --privileged --pid=host docker/desktop-reclaim-space && docker rm $(docker ps -q --filter="ancestor=docker/desktop-reclaim-space")'
alias cmdapp='docker exec -it $(docker ps -q --filter="ancestor=app:latest") /bin/bash'
alias killapp='docker kill $(docker ps -q --filter="ancestor=app:latest")'

alias logapp='ssh -t {host_name} "tail -f /var/log/mberry/app/error_log"'
alias logappapi='./docker-compose.sh logs -f app-api'

function startapp() {
    cd ~/app/ >/dev/null 2>&1 || return
    ./docker-compose.sh "$@" <<EOF
1
2
EOF
    cd - >/dev/null 2>&1 || return
}

alias eks-qa='aws eks --region us-east-1 update-kubeconfig --name AppQA --profile eks-qa; kubectl config set-context --current --namespace=app'
alias eks-prod='aws eks --region us-east-1 update-kubeconfig --name AppProd --profile eks-prod; kubectl config set-context --current --namespace=app'
function dbapp() {
    db=$1
    if [ -z "$db" ]; then
        db="default"
    fi
    docker exec -it "$(docker ps -q --filter="ancestor=app:latest")" /bin/bash -c './am artisan db:cli '$db
}

function de() {
    container=$1
    docker exec -it "$container" /bin/bash
}
alias addbb='eval `ssh-agent`;ssh-add "${SSH_DIR}"/bitbucket'
function addssh() {
    key=$1
    if [ -z "$key" ]; then
        key="bitbucket"
    fi
    eval "$(ssh-agent)"
    ssh-add "${SSH_DIR}""/$key"
}
alias endoflinelf="find -type f -print0 | xargs -0 dos2unix"