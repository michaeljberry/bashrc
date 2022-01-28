#!/bin/bash
## Git Functions

alias nf="newFeature"
alias ftf="finishFeature"
alias pp="prepareAndPush"

###
# Add version number to branch
#
# @param version
###
function gt() {
    version=$1
    git tag -a -m "Tag version $version" "v$version"
}

########################################
#
#  Branch Names
#
########################################

###
# Check if branch name is set and if not prompt for and return a branch name
#
# @param branchType
# @param branchName
#
# @return branchName
###
function branchName() {
    branchType=$1
    branchName=$2
    currentBranchName="$(getbranchname)"
    if [ "$currentBranchName" = "develop" ]; then
        while [ -z "$branchName" ]; do
            read -r -p "Hmm... Looks like you're missing the $branchType branch name. Please enter it: " branchName
        done
        branchName="$branchType-$branchName"
    else
        branchName="$currentBranchName"
    fi
    echo "$branchName"
}

###
# Check if branch version number is set and if not prompt for a branch version
#
# @param versionType
# @param versionNumber
#
# @return versionNumber
###
function versionNumber() {
    versionType=$1
    versionNumber=$2
    while [ -z "$versionNumber" ]; do
        read -r -p "Hmm... Looks like you're missing the $versionType version number. Please enter it: " versionNumber
    done
    echo "$versionNumber"
}

####################
#
# Feature branch names
#
####################

###
# Create Feature branch name if not set
#
# @param featureBranchName
#
# @return featureBranchName
###
function featureName() {
    featureBranchName="$(featureBranchName "$1")"
    echo "$featureBranchName"
}

###
# Format Feature branch name
#
# @param featureBranchName
#
# @return featureBranchName
###
function featureBranchName() {
    featureBranchName="$(branchName "feature" "$1")"
    echo "$featureBranchName"
}

####################
#
# Release branch names
#
####################

###
# Create Release branch name
#
# @param releaseVersionNumber
#
# @return releaseBranchName
###
function releaseName() {
    releaseVersionNumber="$(releaseVersionNumber "$1")"
    releaseBranchName="$(releaseBranchName "$releaseVersionNumber")"
    echo "$releaseBranchName"
}

###
# Format Release branch name
#
# @param releaseBranchName
#
# @return releaseBranchName
###
function releaseBranchName() {
    releaseBranchName="$(branchName "release" "$1")"
    echo "$releaseBranchName"
}

###
# Format Release branch version number
#
# @param releaseVersionNumber
#
# @return releaveVersionNumber
###
function releaseVersionNumber() {
    releaseVersionNumber="$(versionNumber "release" "$1")"
    echo "$releaseVersionNumber"
}

####################
#
# Hotfix branch names
#
####################

###
# Create Hotfix branch name
#
# @param hotfixVersionNumber
#
# @return hotfixBranchName
###
function hotfixName() {
    hotfixVersionNumber="$(hotfixVersionNumber "$1")"
    hotfixBranchName="$(hotfixBranchName "$hotfixVersionNumber")"
    echo "$hotfixBranchName"
}

###
# Format Hotfix branch name
#
# @param hotfixBranchName
#
# @return hotfixBranchName
###
function hotfixBranchName() {
    hotfixBranchName="$(branchName "hotfix" "$1")"
    echo "$hotfixBranchName"
}

###
# Format Hotfix branch version number
#
# @param hotfixVersionNumber
#
# @return hotfixVersionNumber
###
function hotfixVersionNumber() {
    hotfixVersionNumber="$(versionNumber "hotfix" "$1")"
    echo "$hotfixVersionNumber"
}

########################################
#
# Branch Workflows
#
########################################

###
# Merge branch into Master branch
#
# @param branchVersion
# branchName
###
function finishInMaster() {
    branchVersion=$1
    branchName=$2
    git checkout master
    git merge --no-ff "$branchName"
    git tag -a "$branchVersion"
    git push --tags origin master
}

###
# Merge branch into Develop branch
#
# @param branchName
###
function finishInDevelop() {
    branchName=$1
    git checkout develop
    git merge --no-ff "$branchName"
}

###
# Merge branch into Release branch
#
# @param releaseName
# @param branchName
###
function finishInRelease() {
    releaseName=$1
    branchName=$2
    git checkout "$releaseName"
    git merge --no-ff "$branchName"
}

####################
#
# Feature branch workflow
#
####################

###
# Create new Feature branch based on develop branch
#
# @param featureName
###
function newFeature() {
    newFeatureName="$(featureName "$1")"
    git checkout -b "$newFeatureName" develop
}

###
# Finish the currently checked out feature branch and merge with develop
#
# @param featureName
###
function finishFeature() {
    featureName="$(featureName "$1")"
    gitAddAndCommit "feature" "$featureName"
    git checkout develop
    git merge --no-ff "$featureName"
    git branch -d "$featureName"
    git push origin develop
}

####################
#
# Release branch workflow
#
####################

###
# Create new Release branch based on develop branch
#
# @param releaseVersionNumber
###
function newRelease() {
    releaseVersion="$(releaseVersionNumber "$1")"
    releaseName="$(releaseName "$releaseVersion")"
    git checkout -b "$releaseName" develop
}

###
# Finish Release branch with input version number
#
# @param releaseVersionNumber
###
function finishRelease() {
    releaseVersion="$(releaseVersionNumber "$1")"
    releaseName="$(releaseName "$releaseVersion")"
    gitAddAndCommit "release" "$releaseName"
    finishInMaster "$releaseVersion" "$releaseName"
    finishInDevelop "$releaseName"
    git branch -d "$releaseName"
}

####################
#
# Hotfix branch workflow
#
####################

###
# Create new Hotfix branch based on master branch
#
# @param hotfixVersionNumber
###
function newHotfix() {
    hotfixVersion="$(hotfixVersionNumber "$1")"
    hotfixName="$(hotfixName "$hotfixVersion")"
    git checkout -b "$hotfixName" master
}

###
# Finish Hotfix branch and merge to develop branch and optionally release branch
#
# @param hotfixVersionNumber
# @param mergeIntoRelease
# @param releaseVersionNumber
###
function finishHotfix() {
    hotfixVersion="$(hotfixVersionNumber "$1")"
    mergeIntoRelease=$2
    hotfixName="$(hotfixName "$hotfixVersion")"
    gitAddAndCommit "hotfix" "$hotfixName"
    finishInMaster "$hotfixVersion" "$hotfixName"

    # If mergeIntoRelease is not set,
    # If release branch also immediately needs the hotfix
    # Merge hotfix into release branch
    # Then also merge into develop branch
    if [ -z "$mergeIntoRelease" ]; then
        read -r -p "Do you want to merge this hotfix into the release branch as well as the develop branch? (yes/no)" confirmIfWantToMergeToReleaseBranchAlso

        if [ "$confirmIfWantToMergeToReleaseBranchAlso" == "yes" ]; then
            releaseVersion="$(releaseVersionNumber "$3")"
            releaseName="$(releaseName "$releaseVersion")"
            finishInRelease "$releaseName" "$hotfixName"
        fi

        finishInDevelop "$hotfixName"
    fi

    git branch -d "$hotfixName"
}

###
# Add files in branch and commit
#
# @param branchType
# @param brancName
###
function gitAddAndCommit() {
    branchType=$1
    branchName=$2
    branchName="$(branchName "$branchType" "$branchName")"
    commitMessage="$(commitMessage)"
    git add .
    git commit -m "$commitMessage"
}

###
# Prompt for commit message
#
# @return commitMessage
###
function commitMessage() {
    commitMessage=""
    while [ -z "$commitMessage" ]; do
        read -r -p "Please enter your commit message for $branchName: " commitMessage
    done
    echo "$commitMessage"
}

########################################
#
# Project Git functions
#
########################################

#################
#
# @tests
#
# gitJson
# Result: Please type a valid project name:
#
# gitJson blah
# Result: {"name":"blah"}
#
# gitJson blah tv
# Result: {"name":"blah"}
#
# gitJson blah tvp
# Result: {"name":"blah", "private":true}
#################

function gitJson() {
    project=$1
    options=$2

    project="$(inputIsSet "project" "$project")"
    #Assemble JSON string for curl request
    json='{"name":"'$project'"'

    if [[ "$options" == *"p"* ]]; then
        json="$json,\"private\":true"
    fi

    json="$json}"

    echo "$json"
}

#################
#
# @tests
#
# gitVersioning
# Result:
#
# gitVersioning p
# Result:
#
# gitVersioning v
# Result: Versioning...
#################

function gitVersioning() {
    options=$1

    #If 'v' is used in $options, then create version tag
    if [[ "$options" == *"v"* ]]; then
        printf "Versioning... \n"
        git tag -a 0.0.1 -m "First version"
        git push --set-upstream origin master
        git push --tags
    fi
}

#################
#
# @tests
#
# githubCommitMessage
# Result: Please type a valid commit message name:
#
# githubCommitMessage "First Commit"
# Result: First Commit
#################

function githubCommitMessage() {
    message=$1

    message="$(inputIsSet "commit message" "$message")"

    echo "$message"
}

#################
#
# @tests
#
# configureGithub
# Result: Please enter your Github create authorization token or enter 'ng' to prevent Github syncronization:
#
# configureGithub ng
# Result:
#
# configureGithub 12345567890123456asdf
# Result: 12345567890123456asdf
#################

function configureGithub() {
    gitParameter=$1
    tokenType=$2

    if [ -z "$tokenType" ]; then
        tokenType="create"
    fi

    while [ -z "$gitParameter" ]; do
        read -r -p "Please enter your Github $tokenType authorization token or enter 'ng' to prevent Github synchronization: " token
        gitParameter=$token
    done

    echo "$gitParameter"
}

#################
#
# @ tests
#
# setupGithub
# Result: Please type a valid project name:
#
# setupGithub blah
# Result: Please enter your Github create authorization token or enter 'ng' to prevent Github syncronization:
#
# setupGithub blah ng
# Result:
#
# setupGithub blah ng project
# Result:
#
# setupGithub blah ng project tpv
# Result:
#
# setupGithub blah 12345567890123456asdf
# Result: Initializing Git local and remote repos.
#################

function setupGithub() {
    project=$1
    gitParameter=$2
    gitType=$3
    options=$4

    project="$(inputIsSet "project" "$project")"

    if [ -z "$gitType" ]; then
        gitType="project"
    fi

    git="$(configureGithub "$gitParameter")"
    options="$(inputIsSet "option" "$options")"

    if [ "$git" != "ng" ]; then
        printf "Initializing Git local and remote repos. \n"

        touch .gitignore
        if [ $gitType = "package" ]; then
            cat <<EOF >.gitignore
/vendor
.env

EOF
        elif [ $gitType = "project" ]; then
            cat <<EOF >.gitignore
/node_modules
/public/hot
/public/storage
/storage/*.key
/vendor
/.idea
/.vscode
/.vagrant
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log
.env

EOF
        fi

        git init
        git add .
        commitMessage="$(githubCommitMessage -- *glob*)"
        git commit -m "$commitMessage"
        json="$(gitJson "$project" "$options")"
        # Use Github's API to create a new repo on github.com and 2nd @param as access_token
        curl https://api.github.com/user/repos?access_token="$git" -d "$json"
        # Add the newly created github.com repo as the origin to the local repo
        git remote add origin https://github.com/"$github"/"$project".git
        gitVersioning "$options"
        # Push local repo to github.com repo
        git push origin master
    fi
}

function prepareAndPush() {
    project=$1
    project="$(inputIsSet "project" "$project")"

    navigateToProject "$project"
    # Preparing Composer.json for production by replacing local path repos with remote repos
    installedPackages=($(grep -Pazo '(?<=\"type\"\:\s\"path\"\,\n\s{12}\"url\"\:\s\"\.\.\/packages\/).*(?=\"\,)' composer.json | tr '\0' '\n'))
    regexString="s/\"type\"\:\s\"path\"\,\s*?.*?$package\".*?\s*?.*?\s*?.*?\s*?\}/\"type\": \"vcs\",\n            \"url\": \"https:\/\/github.com\/$github\/$package.git\"/"
    adjustComposerRepositories installedPackages "${regexString}"
    composer update
    git add .
    commitMessage="$(githubCommitMessage -- *glob*)"
    git commit -m "$commitMessage"
    git push
    # Preparing Composer.json for development by replacing remote repos with local path repos
    installedPackages=($(grep -Pazo '(?<=\"type\"\:\s\"vcs\"\,\n\s{12}\"url\"\:\s\"https\:\/\/github\.com\/michaeljberry\/)(.*?)(?=\.git\")' composer.json | tr '\0' '\n'))
    regexString="s/\"type\"\:\s\"vcs\"\,\s*?.*?$package\.git\"/\"type\": \"path\",\n            \"url\": \"\.\.\/packages\/$package\",\n            \"options\"\: \{\n                \"symlink\"\: true\n            \}/"
    adjustComposerRepositories "$installedPackages" "${regexString}"
    composer update
}

function pullGithubRepo() {
    project=$1
    gitParameter=$1

    project="$(inputIsSet "project" "$project")"
    git="$(configureGithub "$gitParameter")"
    git clone https://github.com/"$github"/"$project"
}

#################
#
# @tests
#
# teardownGithub
# Result: Please type a valid project name:
#
# teardownGithub test2
# Result: Please enter your Github create authorization token or enter 'ng' to prevent Github syncronization:
#
# teardownGithub test2 ng
# Result:
#
# teardownGithub test2 12345567890123456asdf
# Result: {"message":"Bad credentials"}
#
# teardownGithub test2 realdeleteauthorizationtoken
# Result: GitHub repo is deleted
#################

function teardownGithub() {
    project=$1
    gitParameter=$2

    project="$(inputIsSet "project" "$project")"
    git="$(configureGithub "$gitParameter")"

    if [ "$git" != "ng" ]; then
        curl -X DELETE -H "Authorization: token $git" https://api.github.com/repos/"$github"/"$project"
    fi
}

function gll() {
    line=$1
    file=$2
    git log -L "$line","$line":"$file"
}
