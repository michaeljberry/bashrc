source ~/env.sh
source ~/aliases.sh

dev(){

    folder=$1

    printf "Navigating to Dev root folder... \n"

    cd ~
    cd $rootdevfolder

    if [ ! -z "$folder" ]; then

        navigateToProject $project

    fi

}

lara(){

    dev

    printf "Navigating to Docker containers... \n"
    cd laradock

}

dbash() {

    commands=$1

    lara

    printf "Starting up Docker bash shell... \n"

    if [ ! -z "$commands" ]; then

        winpty docker-compose exec --user=laradock workspace bash -c 'cd '$commands' && pwd && php artisan migrate:fresh --seed'

    else

        winpty docker-compose exec --user=laradock workspace bash

    fi

}

dmaria() {

    lara

    winpty docker-compose exec mariadb sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot'

}

dcont() {

    container=$1

    winpty docker exec -it "$container" bash;

}

dk(){

    lara

    docker-compose kill

}

dup() {

    options=$1

    lara

    printf "Starting Docker containers... \n"

    string="docker-compose up -d"

    if [[ "$options" == *"n"* ]]; then

        string="$string nginx"

    fi

    if [[ "$options" == *"m"* ]]; then

        string="$string mariadb"

    fi

    if [[ "$options" == *"p"* ]]; then

        string="$string phpmyadmin"

    fi

    if [[ "$options" == *"r"* ]]; then

        string="$string redis"

    fi

    $string

}

gt(){

    version=$1
    git tag -a -m "Tag version $version" "v$version"

}

export XDEBUG_CONFIG="idekey=VSCODE"

openEditor(){

    project=$1

    dev

    if [ -d "$project" ]; then

        printf "Opening $project project in VSC \n"
        code $project

        cd $project

    fi

}

#################
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
#################

inputType(){

    inputType=$1

    if [ -z "$inputType" ]; then

        inputType="folder"

    fi

    echo "$inputType"

}

#################
#
# @tests
#
# shouldFolderBeCreated
# Result: false
#
# shouldFolderBeCreated true
# Result: true
#################

shouldFolderBeCreated(){

    shouldFolderBeCreated=$1

    if [ -z $shouldFolderBeCreated ]; then

        shouldFolderBeCreated=false

    fi

    echo "$shouldFolderBeCreated"

}

#################
#
# @tests
#
# createFolder
# Result:
#
# createFolder blah
# Result: Blah
#################

createFolder(){

    folder=$1

    folder="$(inputIsSet "folder" "$folder")"

    mkdir $folder

    echo "$folder"

}

#################
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
#################

createFolderIfNeeded(){

    folder=$1
    shouldFolderBeCreated=$2

    shouldFolderBeCreated="$(shouldFolderBeCreated "$shouldFolderBeCreated")"

    if [ "$shouldFolderBeCreated" = "true" ]; then

        folder="$(createFolder "$folder")"
        echo "$folder"

    fi

}

#################
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
#################

validFolderName(){

    folder=$1
    folderType=$2

    folderType="$(inputType "$folderType")"

    while [ ! -d "$folder" ]; do

        read -p "Please type a valid $folderType name: " folder
        folder="$folder"

    done

    echo "$folder"

}

#################
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
#################

inputIsSet(){

    inputType=$1
    input=$2

    inputType="$(inputType "$inputType")"

    while [ -z "$input" ]; do

        read -p "Please type a valid $inputType name: " input
        input="$input"

    done

    echo "$input"

}

#################
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
#################

folderExists(){

    folder=$1
    folderType=$2

    folderType="$(inputType "$folderType")"

    folder="$(validFolderName "$folder" "$folderType")"

    echo "$folder"

}

#################
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
#################

navigateToFolder(){

    folder=$1
    shouldFolderBeCreated=$2
    folderType=$3

    folderType="$(inputType "$folderType")"

    createdFolder="$(createFolderIfNeeded "$folder" "$shouldFolderBeCreated")"

    folder="$(folderExists "$folder" "$folderType")"

    if [ ! -z "$folder" ]; then

        cd $folder

    fi


}

#################
#
# @tests
#
# navigateToProject
# Result: Please type a valid project name:
#
# navigateToProject blah
# Result: Please type a valid project name:
#
# navigateToProject michaeljberry
# Result: /michaeljberry
#################

navigateToProject(){

    project=$1

    dev

    navigateToFolder "$project" "false" "project"

}

#################
#
# @tests
#
# startup
# Result: Please type a valid project name:
#
# startup blah
# Result: Please type a valid project name:
#
# startup michaeljberry
# Result: /laradock
# Result: Docker containers running, Project migrated
#################

startup(){

    project=$1
    navigateToProject "$project"

    printf "Starting $project. Just a minute... \n"

    lara

    dup nmp

    setupProject "$project" "ng"

    # lara

    printf "Running initial migrations... \n"
    dbash "$project"

}

#################
#
# @tests
#
# migrateProject
# Result: Please type a valid project name:
#
# migrateProject blah
# Result: Please type a valid project name:
#
# migrateProject michaeljberry
# Result: /laradock
# Result: Project migrated with fresh migration and re-seeded
#################

migrateproject(){

    project=$1

    dev

    project="$(folderExists "$project" "project")"

    echo "$project"
    lara

    dbash "$project"

}

#################
#
# @tests
#
# setupLaravel
# Result: Please type a valid project name:
#
# setupLaravel test
# Result: /test
# Result: New Laravel project setup
#################

setupLaravel(){

    project=$1

    dev

    project="$(inputIsSet "project" "$project")"

    printf "Setting up $project... \n"
    laravel new $project

    navigateToProject "$project"

    printf "Generating a new key... \n"
    php artisan key:generate

}

#################
#
# @tests
#
# teardownLaravel
# Result: Please type a valid project name:
#
# teardownLaravel blah
# Result: Please type a valid project name:
#
# teardownLaravel test2
# Result: Project is deleted
#
# teardownLaravel .htaccess
# Result: Please type a valid project name:
#################

teardownLaravel(){

    project=$1

    project="$(inputIsSet "project" "$project")"

    project="$(validFolderName "$project" "project")"

    rm -rf $project

}

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

gitJson(){

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

gitVersioning(){

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

githubCommitMessage(){

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

configureGithub(){

    configureGithub=false
    githubConfigured=false
    gitParameter=$1
    tokenType=$2

    if [ -z "$tokenType" ]; then

        tokenType="create"

    fi

    while [ -z "$gitParameter" ]; do

        read -p "Please enter your Github $tokenType authorization token or enter 'ng' to prevent Github synchronization: " token
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

setupGithub(){

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

        cat << EOF > .gitignore
/vendor
.env

EOF

        elif [ $gitType = "project" ]; then

        cat << EOF > .gitignore
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

        commitMessage="$(githubCommitMessage)"

        git commit -m "$commitMessage"

        json="$(gitJson "$project" "$options")"

        # Use Github's API to create a new repo on github.com and 2nd @param as access_token
        curl https://api.github.com/user/repos?access_token=$git -d $json

        # Add the newly created github.com repo as the origin to the local repo
        git remote add origin https://github.com/$github/$project.git

        gitVersioning $options

        # Push local repo to github.com repo
        git push origin master

    fi

}

adjustComposerRepositories(){

    packages=$1[@]
    regexString=$2

    installedPackages=("${!packages}")

    for package in ${installedPackages[@]}; do
        printf "$package\n"
        perl -0777 -pi -e "${regexString//\$package/$package}" composer.json
    done

}


prepareAndPush(){

    project=$1

    project="$(inputIsSet "project" "$project")"

    navigateToProject "$project"

    # Preparing Composer.json for production by replacing local path repos with remote repos

    installedPackages=($(grep -Pazo '(?<=\"type\"\:\s\"path\"\,\n\s{12}\"url\"\:\s\"\.\.\/packages\/).*(?=\"\,)' composer.json | tr '\0' '\n'))
    regexString='s/\"type\"\:\s\"path\"\,\s*?.*?$package\".*?\s*?.*?\s*?.*?\s*?\}/\"type\": \"vcs\",\n            \"url\": \"https:\/\/github.com\/'$github'\/$package.git\"/'

    adjustComposerRepositories installedPackages "${regexString}"

    composer update

    git add .

    commitMessage="$(githubCommitMessage)"

    git commit -m "$commitMessage"

    git push

    # Preparing Composer.json for development by replacing remote repos with local path repos

    installedPackages=($(grep -Pazo '(?<=\"type\"\:\s\"vcs\"\,\n\s{12}\"url\"\:\s\"https\:\/\/github\.com\/michaeljberry\/)(.*?)(?=\.git\")' composer.json | tr '\0' '\n'))
    regexString='s/\"type\"\:\s\"vcs\"\,\s*?.*?$package\.git\"/\"type\": \"path\",\n            \"url\": \"\.\.\/packages\/$package\",\n            \"options\"\: \{\n                \"symlink\"\: true\n            \}/'

    adjustComposerRepositories installedPackages "${regexString}"

    composer update

}

alias pp="prepareAndPush"

pullGithubRepo(){

    project=$1
    gitParameter=$1

    project="$(inputIsSet "project" "$project")"

    git="$(configureGithub "$gitParameter")"

    git clone https://github.com/$github/$project
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

teardownGithub(){

    project=$1
    gitParameter=$2

    project="$(inputIsSet "project" "$project")"

    git="$(configureGithub "$gitParameter")"

    if [ "$git" != "ng" ]; then

        curl -X DELETE -H "Authorization: token $git" https://api.github.com/repos/$github/$project

    fi

}

#################
#
# Windows Git Bash users must include 'winpty' at beginning to create sub-shell
# Exports MySQL password into mysql shell
# Logins as 'root' user
# In MySQL:
#  Executes commands to create a database
#  Executes command to create a user
#  Grants user all privileges on newly created database for all hosts
#  **Optional (This displays the list of databases and should now include the newly created database)
#  **Just add this command after the `GRANT ALL ON` command:
#        SHOW DATABASES;
#
#################

setupDatabase(){

    project=$1

    project="$(inputIsSet "project" "$project")"

    lara

    winpty docker-compose exec mariadb sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot --execute "
    CREATE DATABASE IF NOT EXISTS '$project'_testing COLLATE utf8_general_ci;
    GRANT ALL PRIVILEGES ON '$project'_testing.* TO '"'"''$project''"'"'@'"'"'%'"'"' IDENTIFIED BY '"'"''$project''"'"';
    SHOW DATABASES;
    SHOW GRANTS FOR '$project';
    FLUSH PRIVILEGES;
    ";'

}

#################
#
#  Windows Git Bash users must include 'winpty' at beginning to create sub-shell
#  Exports MySQL password into mysql shell
#  Logins as 'root' user
#  In MySQL:
#    Executes commands to delete the database
#    Executes command to delete the user
#
#################

teardownDatabase(){

    lara

    winpty docker-compose exec mariadb sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot --execute "
    DROP DATABASE IF EXISTS 'project'_testing;
    DROP USER IF EXISTS '$project';
    SHOW DATABASES;
    SHOW GRANTS FOR '$project'@'"'"'%'"'"';
    FLUSH PRIVILEGES;
    ";'

}

#################
#
# @tests
#
# createEnv
# Result: Please type a valid project name:
#
# createEnv test2
# Result:
#
# createEnv test2 true
# Result: Default .env file created.
#################

createEnv(){

    project=$1
    shouldEnvBeCreated=$2

    project="$(inputIsSet "project" "$project")"

    if [ $shouldEnvBeCreated = "true" ]; then

        touch .env

        cat << EOF > .env
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_LOG_LEVEL=debug
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=homestead
DB_USERNAME=homestead
DB_PASSWORD=secret

BROADCAST_DRIVER=log
CACHE_DRIVER=file
SESSION_DRIVER=file
SESSION_LIFETIME=120
QUEUE_DRIVER=sync

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_DRIVER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_APP_CLUSTER=mt1

EOF

    fi
}

configureEnv(){

    project=$1
    shouldEnvBeCreated=$2

    project="$(inputIsSet "project" "$project")"

    dev

    cd $project

    printf "Configuring .env \n"

    createEnv "$project" "$shouldEnvBeCreated"

    # Change host in new Laravel app's .env to Laradock host 'mysql'
    sed -i -e "s/DB_HOST=127.0.0.1/DB_HOST=mariadb/g" .env

    # Change database in new Laravel app's .env to newly created database
    sed -i -e "s/DB_DATABASE=homestead/DB_DATABASE=${project}_testing/g" .env

    # Change user in new Laravel app's .env to newly created user
    sed -i -e "s/DB_USERNAME=homestead/DB_USERNAME=$project/g" .env

    # Change passowrd in new Laravel app's .env to newly created password
    sed -i -e "s/DB_PASSWORD=secret/DB_PASSWORD=$project/g" .env

}

configureTest(){

    project=$1
    options=$2

    project="$(inputIsSet "project" "$project")"

    dev

    cd $project

    if [[ "$options" == *"t"* ]]; then

        printf "Configuring phpunit.xml \n"

        sed -i -e '/<env name=\"APP_ENV\" value=\"testing\"\/>/a\
        <env name=\"DB_CONNECTION\" value=\"sqlite\"\/>\
        <env name=\"DB_DATABASE\" value=\":memory:\"\/>' phpunit.xml

        printf "Creating testing helper functions \n"

        mkdir tests/Utilities

        touch tests/Utilities/functions.php

        cat << EOF > tests/Utilities/functions.php
<?php

function create(\$class, \$attributes = [], \$times = null)
{
    return factory(\$class, \$times)->create(\$attributes);
}

function make(\$class, \$attributes = [], \$times = null)
{
    return factory(\$class, \$times)->make(\$attributes);
}
EOF

        printf "Editing composer.json to require new helper functions file \n"

        perl -0777 -pi -e 's/\"tests\/\"\n\s*\}/\"tests\/\"\n        \},\n        \"files\"\: \[\"tests\/utilities\/functions.php\"\]/' composer.json

        printf "Dumping and reloading composer dependencies \n"

        composer dump-autoload

    fi

}

installProject(){

    project=$1
    gitParameter=$2
    options=$3

    project="$(inputIsSet "project" "$project")"

    git="$(configureGithub "$gitParameter" "repo")"

    printf "Installing application ...\n"

    dev

    pullGithubRepo "$project" "$gitParameter"

    composer install

    dup nmp

    setupDatabase "$project"

    configureEnv "$project" "true"

    php artisan key:generate

    openEditor "$project"

}

#################
#
# @param1 string project-name
# @param2 string Github Personal Access Token with full repo scope OR 'ng' (No Git)
# @param3 string p
#
# Example:
# setup todo 1234567890qwertyuiop
#
#################

setupProject(){

    project=$1
    gitParameter=$2
    options=$3

    project="$(inputIsSet "project" "$project")"

    git="$(configureGithub "$gitParameter")"

    printf "Booting application... \n"

    setupLaravel "$project"

    dup nmp

    setupGithub "$project" "$gitParameter" "project" "$options"

    setupDatabase "$project"

    configureEnv "$project"

    configureTest "$project" "$options"

    openEditor "$project"

}

alias spr="setupProject"

#################
#
# @param1 string project-name
# @param2 string Github Personal Access Token with delete_repo scope or 'ng' (No GitHub)
#
# Example:
# teardown todo 0987654321poiuytrewq
#
#################

teardown(){

    project=$1
    gitParameter=$2

    project="$(inputIsSet "project" "$project")"

    git="$(configureGithub "$gitParameter" "delete")"

    dev

    if [ -d "$project" ]; then

        printf "The directory $project exists. \n"

        teardownLaravel "$project"

        teardownGithub "$project" "$git"

        teardownDatabase "$project"

        dev

    else

        printf "The directory $project doesn\'t exist \n"

    fi

}

setupPackage(){

    project=$1
    package=$2
    gitParameter=$3
    options=$4

    project="$(inputIsSet "project" "$project")"

    package="$(inputIsSet "package" "$package")"

    git="$(configureGithub "$gitParameter")"

    navigateToProject "$project"

    if [ ! -d "vendor/michaeljberry/laravel-packager" ]; then

        printf "Installing laravel-packager... \n"

        # regexstring="\"require\"\:\s\{(?s).*?\"(?=\n\s*\})\K"
        # search="composer.json"

        # if grep "$regexstring" "$search"; then

        #     echo "Howdy!"

        # fi

        perl -0777 -pi -e 's/\"require-dev\"\:\s\{(?s).*?(?=\s*\})\K/,\n        \"michaeljberry\/laravel-packager\": \"dev-master\"/' composer.json

        perl -0777 -pi -e 's/\"config\"\:\s*\{(?s).*?\}\K/,\n    \"repositories\": \[\n        \{\n            \"type\": \"vcs\",\n            \"url\": \"https:\/\/github.com\/michaeljberry\/laravel-packager.git\"\n        \}\n    \]/' composer.json

        composer update --lock

        composer install

    else

        printf "Looks like laravel-packager is already installed... \n"

    fi

    directory=$(pwd -W)

    if [ ! -d "../packages/$package" ]; then

        printf "Creating a new package... \n"
        php artisan packager:new $githubname ${package^}
    #     #vendordirectory="$directory\\vendor\\$github\\$project"
    #     #packageDirectory="$(dirname "$directory")"
    #     #packageDirectory="$packageDirectory\\packages\\$project"
    #     #symlink="mklink /D \"${vendordirectory//\//\\}\" \"${packageDirectory//\//\\}\""
    #     #printf "Creating the symlink... \n"
    #     #cmd /c <<< "$symlink"
    #     #cmd /c <<< exit

    else

        printf "Updating your package... \n"

    fi

    if [ -d "../packages/$package" ]; then

        cd ../packages/$package

        printf "Configuring automatic package discovery... \n"
        perl -0777 -pi -e 's/\"extra\"\: \{(?=\s)\K/\n        \"laravel\"\: \{\n            \"providers\"\:\[\n                \"'$githubname'\\\\'${package^}'\\\\'${package^}'ServiceProvider\"\n            \]\n        \},/' composer.json
        perl -0777 -pi -e "s/\:author\_name/${fullname}/" composer.json
        perl -0777 -pi -e "s/\:author\_email/${emailaddress}/" composer.json
        perl -0777 -pi -e "s/\:author\_website/${website}/" composer.json

        setupGithub $package $git "package" $options

        cd "$directory"

        printf "Configuring composer.json before install... \n"

        perl -0777 -pi -e 's/\"require\"\:\s\{(?s).*?(?=\s*\})\K/,\n        \"'$github'\/'$package'\": \"dev\-master\"/' composer.json

        perl -0777 -pi -e 's/\"repositories\"\:\s*\[(?s).*?\}\K/,\n        \{\n            \"type\": \"path\",\n            \"url\": \"\.\.\/packages\/'$package'\",\n            \"options\"\:\{\n                \"symlink\"\: true\n            \}\n        \}/' composer.json

        composer update

    fi

}

installPackage(){

    project=$1
    package=$2

    project="$(inputIsSet "project" "$project")"

    package="$(inputIsSet "package" "$package")"

    printf "Configuring composer.json before install... \n"

    perl -0777 -pi -e 's/\"require\"\:\s\{(?s).*?\"(?=\n\s*\})\K/,\n        \"'$github'\/'$package'\": \"dev\-master\"/' composer.json

    repositories="\"repositories\""
    search="composer.json"

    if grep "$repositories" "$search"; then

        perl -0777 -pi -e 's/\"repositories\"\:\s\[(?s).*?(?=\s*\])\K/,\n        \{\n            \"type\": \"path\",\n            \"url\": \"\.\.\/packages\/'$package'\",\n            \"options\"\: \{\n                \"symlink\"\: true\n            \}\n        \}/' composer.json

    else

        perl -0777 -pi -e 's/\}(?=\n\})\K/,\n    \"repositories\": \[\n        \{\n            \"type\": \"path\",\n            \"url\": \"\.\.\/packages\/'$package'\",\n            \"options\"\: \{\n                \"symlink\"\: true\n            \}\n        \}\n    \]/' composer.json

    fi

    composer update

}

navigateToPackage(){

    package=$1
    createPackage=$2

    package="$(inputIsSet "package" "$package")"

    dev

    cd packages

    if [ -z "$createPackage" ]; then
        createPackage=false
    fi

    navigateToFolder "$package" "$createPackage" "package"

}

configureServiceProvider(){

    search=$1
    configure=$2
    replacement=$3

    serviceProvider="${packageDirectoryUpperCase}ServiceProvider.php"
    find="boot\(\)\s*\{(?s)\K"

    if grep "$search" "$serviceProvider"; then

        printf "${configure^} are already loaded in boot()... \n"

    else

        printf "Configuring $serviceProvider to load $configure... \n"
        perl -0777 -pi -e "s/$find/$replacement/" $serviceProvider

    fi

}

packageController(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    controllerName="$(inputIsSet "Controller" "$componentName")"

    cd src
    mkdir Controllers
    cd Controllers

    printf "Creating controller... \n"

    controllerNameUpperCase="${controllerName^}"

    touch "${controllerNameUpperCase}Controller".php

    cat << EOF > "${controllerNameUpperCase}Controller".php
<?php

namespace $githubname\\$packageDirectoryUpperCase\\Controllers;

use Illuminate\\Http\\Request;
use App\\Http\\Controllers\\Controller;
use $githubname\\$packageDirectoryUpperCase\\$controllerNameUpperCase;

class ${controllerNameUpperCase}Controller extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \\Illuminate\\Http\\Response
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \\Illuminate\\Http\\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \\Illuminate\\Http\\Request  \$request
     * @return \\Illuminate\\Http\\Response
     */
    public function store(Request \$request)
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  \\$githubname\\$packageDirectoryUpperCase\\$controllerNameUpperCase  \$$controllerName
     * @return \\Illuminate\\Http\\Response
     */
    public function show($controllerNameUpperCase \$$controllerName)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \\$githubname\\$packageDirectoryUpperCase\\$controllerNameUpperCase  \$$controllerName
     * @return \\Illuminate\\Http\\Response
     */
    public function edit($controllerNameUpperCase \$$controllerName)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \\Illuminate\\Http\\Request  \$request
     * @param  \\$githubname\\$packageDirectoryUpperCase\\$controllerNameUpperCase  \$$controllerName
     * @return \\Illuminate\\Http\\Response
     */
    public function update(Request \$request, $controllerNameUpperCase \$$controllerName)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \\$githubname\\$packageDirectoryUpperCase\\$controllerNameUpperCase  \$$controllerName
     * @return \\Illuminate\\Http\\Response
     */
    public function destroy($controllerNameUpperCase \$$controllerName)
    {
        //
    }
}
EOF

    dev

}

packageFactory(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    factoryName="$(inputIsSet "Factory" "$componentName")"

    modelName="$(inputIsSet "Model" "$componentName")"

    cd src
    mkdir Factories
    cd Factories

    printf "Creating factory... \n"

    factoryNameUpperCase="${factoryName^}"

    touch "${factoryNameUpperCase}Factory".php

    cat << EOF > "${factoryNameUpperCase}Factory".php
<?php

use Faker\Generator as Faker;

\$factory->define($githubname\\$packageDirectoryUpperCase\\$modelName::class, function (Faker \$faker) {
    return [
        //
    ];
});
EOF

    dev

}

packageModel(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    modelName="$(inputIsSet "Model" "$componentName")"

    cd src
    mkdir Models
    cd Models

    printf "Creating model... \n"

    modelNameUpperCase="${modelName^}"

    touch "${modelNameUpperCase}".php

    cat << EOF > "${modelNameUpperCase}".php
<?php

namespace $githubname\\$packageDirectoryUpperCase;

use Illuminate\Database\Eloquent\Model;

class $modelNameUpperCase extends Model
{
    //
}
EOF

    dev

}

packageRoute(){

    package=$1

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    routeName="$(inputIsSet "Route" "routes")"

    cd src
    mkdir Routes
    cd Routes

    printf "Creating route... \n"

    routeNameUpperCase="${routeName^}"

    touch "${routeNameUpperCase}".php

    cat << EOF > "${routeNameUpperCase}".php
<?php

Route::get('/', function () {
    return view('welcome');
});
EOF

    cd ..

    search="loadRoutesFrom"
    configure="routes"
    replacement='\n        \$this\-\>'$search'\(\_\_DIR\_\_ \. \"\/Routes\/'$routeNameUpperCase'.php\"\)\;'

    configureServiceProvider "$search" "$configure" "$replacement"

    dev

}

packageSeeder(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    seederName="$(inputIsSet "Seeder" "$componentName")"

    cd src
    mkdir Seeders
    cd Seeders

    printf "Creating seeder... \n"

    seederNameUpperCase="${seederName^}"

    touch "${seederNameUpperCase}TableSeeder".php

    cat << EOF > "${seederNameUpperCase}TableSeeder".php
<?php

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ${seederNameUpperCase}TableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        //
    }
}
EOF
    dev

}

packageMigration(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    migrationName="$(inputIsSet "Migration" "$componentName")"

    cd src
    mkdir Migrations
    cd Migrations

    printf "Creating migration... \n"

    migrationNameUpperCase="${migrationName^}"
    timestamp="$(date +"%Y_%m_%d_%H%M%S")"

    touch "${timestamp}_create_${migrationName}_table".php

    cat << EOF > "${timestamp}_create_${migrationName}_table".php
<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class Create${migrationNameUpperCase}Table extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('$migrationName', function (Blueprint \$table) {
            \$table->increments('id');
            \$table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('$migrationName');
    }
}
EOF

    cd ..

    search="loadMigrationsFrom"
    configure="migrations"
    replacement='\n        \$this\-\>'$search'\(\_\_DIR\_\_ \. \"\/Migrations\"\)\;'

    configureServiceProvider "$search" "$configure" "$replacement"

    dev

}

packageView(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    viewName="$(inputIsSet "View" "$componentName")"

    cd src
    mkdir Views
    cd Views

    printf "Creating view... \n"

    mkdir -p "$(dirname "$viewName")" || exit

    cat << EOF > "${viewName}".blade.php

EOF

    cd ..

    search="loadViewsFrom"
    configure="views"
    replacement='\n        \$this\-\>'$search'(\_\_DIR\_\_ \. \"\/Views\"\, \"'$package'\"\)\;'

    configureServiceProvider "$search" "$configure" "$replacement"

    dev

}

packageConfig(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    configName="$(inputIsSet "config file" "$componentName")"

    cd src
    mkdir Config
    cd Config

    printf "Creating config file... \n"

    mkdir -p "$(dirname "$configName")" || exit

    cat << EOF > "${configName}Config".php
<?php

return [

];
EOF
    cd ..

    search="mergeConfigFrom"
    configure="config files"
    replacement='\n        \$this\-\>'$search'(\_\_DIR\_\_ \. \"\/Config\"\, \"'$package'\"\)\;'

    configureServiceProvider "$search" "$configure" "$replacement"

    dev

}

packageMiddleware(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    middlewareName="$(inputIsSet "middleware" "$componentName")"

    cd src
    mkdir Middleware
    cd Middleware

    printf "Creating middleware... \n"

}

packageTest(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    testName="$(inputIsSet "test" "$componentName")"

    cd src
    mkdir Tests
    cd Tests

    printf "Creating middleware... \n"

}

packageComposer(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    composerName="$(inputIsSet "composer" "$componentName")"

    cd src
    mkdir Composers
    cd Composers

    printf "Creating composers... \n"

}

packageAssets(){

    package=$1
    componentName=$2

    navigateToPackage "$package"

    packageDirectoryUpperCase="${package^}"

    cd src
    mkdir Assets
    cd Assets

    printf "Creating assets... \n"

    cd ..

    search="publishes"
    configure="assets"
    replacement='\n        \$this\-\>'$search'([\_\_DIR\_\_ \. \"\/Assets\" \=\> public_path\(\"'$package'\"\)\]\, \"public\"\)\;'

    configureServiceProvider "$search" "$configure" "$replacement"

    dev

}