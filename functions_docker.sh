#!/bin/bash
## Docker Functions
function lara() {
    dev

    printf "Navigating to Docker containers... \n"
    cd laradock
}

function dbash() {
    commands=$1

    lara

    printf "Starting up Docker bash shell... \n"

    if [ ! -z "$commands" ]; then
        winpty docker-compose exec --user=laradock workspace bash -c 'cd '$commands' && pwd && php artisan migrate:fresh --seed'
    else
        winpty docker-compose exec --user=laradock workspace bash
    fi
}

function dmaria() {
    lara
    winpty docker-compose exec mariadb sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot'
}

function dcont() {
    container=$1

    winpty docker exec -it "$container" bash
}

function dk() {
    lara
    docker-compose kill
}

function dup() {
    options=$1

    lara

    printf "Starting Docker containers... \n"

    string="docker-compose up -d workspace"

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

    printf "$string\n"

    $string
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

function setupDatabase() {
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

function teardownDatabase() {
    lara
    winpty docker-compose exec mariadb sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot --execute "
    DROP DATABASE IF EXISTS 'project'_testing;
    DROP USER IF EXISTS '$project';
    SHOW DATABASES;
    SHOW GRANTS FOR '$project'@'"'"'%'"'"';
    FLUSH PRIVILEGES;
    ";'
}

function de() {
    container=$1
    docker exec -it $container /bin/bash
}
