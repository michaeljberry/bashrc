#!/usr/bin/env bash

# Change directory to match your dev location
devfolder="~/Desktop/Dev"

# Github username
github="michaeljberry"

# Alias to change directory to devfolder
alias dev="cd $devfolder"

# Alias to change directory to laradock folder
alias lara="cd $devfolder/laradock"

# Change as needed to match your code editor's location
alias idea="\"/c/Program Files (x86)/JetBrains/IntelliJ IDEA 2017.1/bin/idea64.exe\""

setuplaravel(){

    # setup new Laravel app
    laravel new $1

    # cd into new Laravel app directory
    cd $1

    # Generate the APP_KEY in your .env file
    php artisan key:generate

}

teardownlaravel(){

    # Delete the files...
    rm -rf $1

}

setupgithub(){

    # If a Github repo should be created
    if [ "$2" != "ng" ]; then

        echo "Initializing Git local and remote repos."

        # Initialize local repo
        git init

        # Add all files to repo
        git add .

        # Create the initial commit
        git commit -m "First commit"

        #Assemble JSON string for curl request
        json='{"name":"'$1'"'
        if [[ "$3" == *"p"* ]]; then
            json="$json,\"private\":true"
        fi
        json="$json}"

        # Use Github's API to create a new repo on github.com  and 2nd @param as access_token
        curl https://api.github.com/user/repos?access_token=$2 -d $json

        # Add the newly created github.com repo as the origin to the local repo
        git remote add origin https://github.com/$github/$1.git

        # Push local repo to github.com repo
        git push origin master

    fi

}

teardowngithub(){

    # If a Github repo should be deleted, delete the repo...
    if [ "$2" != "ng" ]; then

        curl -X DELETE -H "Authorization: token $2" https://api.github.com/repos/$github/$1

    fi

}

setupdatabase(){

    # cd to laradock folder
    lara

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

    winpty docker-compose exec mariadb sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot --execute "
    CREATE DATABASE IF NOT EXISTS '$1'_testing COLLATE utf8_general_ci;
    GRANT ALL PRIVILEGES ON '$1'_testing.* TO '"'"''$1''"'"'@'"'"'%'"'"' IDENTIFIED BY '"'"''$1''"'"';
    SHOW DATABASES;
    SHOW GRANTS FOR '$1';
    FLUSH PRIVILEGES;
    ";'

}

teardowndatabase(){

    # cd to laradock folder
    lara

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

    winpty docker-compose exec mariadb sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot --execute "
    DROP DATABASE IF EXISTS '$1'_testing;
    DROP USER IF EXISTS '$1';
    SHOW DATABASES;
    SHOW GRANTS FOR '$1'@'"'"'%'"'"';
    FLUSH PRIVILEGES;
    ";'

}

configureenv(){

    # cd to dev folder
    dev

    # cd to new project folder
    cd $1

    echo "Configuring .env"

    # Change host in new Laravel app's .env to Laradock host 'mysql'
    sed -i -e "s/DB_HOST=127.0.0.1/DB_HOST=mariadb/g" .env

    # Change database in new Laravel app's .env to newly created database
    sed -i -e "s/DB_DATABASE=homestead/DB_DATABASE=$1_testing/g" .env

    # Change user in new Laravel app's .env to newly created user
    sed -i -e "s/DB_USERNAME=homestead/DB_USERNAME=$1/g" .env

    # Change passowrd in new Laravel app's .env to newly created password
    sed -i -e "s/DB_PASSWORD=secret/DB_PASSWORD=$1/g" .env

}

configuretest(){

    # cd to dev folder
    dev

    # cd to new project folder
    cd $1

    if [[ "$2" == *"t"* ]]; then

        echo "Configuring phpunit.xml"

        sed -i -e '/<env name=\"APP_ENV\" value=\"testing\"\/>/a\
        <env name=\"DB_CONNECTION\" value=\"sqlite\"\/>\
        <env name=\"DB_DATABASE\" value=\":memory:\"\/>' phpunit.xml

        echo "Creating testing helper functions"

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

        echo "Editing composer.json to require new helper functions file"

        perl -0777 -pi -e 's/\"tests\/\"\n\s*\}/\"tests\/\"\n        \},\n        \"files\"\: \[\"tests\/utilities\/functions.php\"\]/' composer.json

        echo "Dumping and reloading composer dependencies"

        composer dump-autoload

    fi

}

openeditor(){

    # cd to dev folder
    dev

    #Opens IntelliJ Idea to new project
    if [ -d "$1" ]; then

        echo "Opening IntelliJ project for $1"
        idea $1

        # cd to new project folder
        cd $1

    fi

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

setup(){

    if [ -z "$2" ] && [ "$2" != "ng" ]; then

        echo "Please enter your Github authorization token."

    else

        # cd to dev folder
        dev

        setuplaravel $1

        setupgithub $1 $2 $3

        setupdatabase $1

        configureenv $1

        configuretest $1 $3

        openeditor $1

    fi

}

#################
#
# @param1 string project-name
# @param2 string Github Personal Access Token with delete_repo scope or 'ng' (No GitHub)
#
# Example:
# teardown todo 0987654321poiuytrewq
#
#################

# If 2nd parameter is empty and doesn't equal 'ng', then we need a Github token
teardown(){

    if [ -z "$2" ]; then

        echo "Please enter your Github delete authorization token."

    else
        # cd to dev folder
        dev

        # If the project directory exists, then...
        if [ -d "$1" ]; then

            echo "The directory $1 exists."

            teardownlaravel $1

            teardowngithub $1 $2

            teardowndatabase $1

           # cd to dev folder
            dev

        else

            echo "The directory $1 doesn\'t exist"

        fi

    fi

}
