# Change to your dev location
alias dev="cd ~/Desktop/Dev"

# For use later to automatically open code editor to new project
alias idea="\"/c/Program Files (x86)/JetBrains/IntelliJ IDEA 2017.1/bin/idea64.exe\""


<<"COMMENT"

For the automated setup of local files, Laravel application, Github repo, database including user, 
configuration of Laravel .env file and opening of code editor to the newly created project.

@param string project-name
@param string Github Personal Access Token with full repo scope OR 'ng' (No Github)

Example:
setup todo 1234567890qwertyuiop

COMMENT

setup(){

# If 2nd parameter is empty AND doesn't equal 'ng', then we need a Github token
if [ -z "$2" ] && [ "$2" != "ng" ]; then
    echo "Please enter your Github authorization token."
else
    # cd to dev location
    dev
    
    # setup new Laravel app
    laravel new $1
    
    # cd into new Laravel app directory
    cd $1
    
    # Generate the APP_KEY in your .env file
    php artisan key:generate
    
    # If a Github repo should be created
    if [ "$2" != "ng" ]; then
        echo "Initializing Git local and remote repos."
        
        # Initialize local repo
        git init
        
        # Add all files to repo
        git add .
        
        # Create the initial commit
        git commit -m "First commit"
        
        # Use Github's API to create a new repo on github.com with the 1st @param as its name and 2nd @param as access_token
        curl https://api.github.com/user/repos?access_token=$2 -d '{"name":"'$1'"}'
        
        # Add the newly created github.com repo as the origin to the local repo
        git remote add origin https://github.com/{username}/$1.git
        
        # Push local repo to github.com repo
        git push origin master
    fi

    # cd to laradock folder
    cd ~/Desktop/Dev/laradock
    
    
    <<"COMMENT" 
    
    Windows Git Bash users must include 'winpty' at beginning to create sub-shell
    Exports MySQL password into mysql shell
    Logins as 'root' user
    In MySQL:
      Executes commands to create a database
      Executes command to create a user
      Grants user all privileges on newly created database for all hosts
      
    COMMENT
    
    winpty docker-compose exec mysql sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot --execute "
    CREATE DATABASE IF NOT EXISTS '$1'_testing COLLATE utf8_general_ci;
    CREATE USER IF NOT EXISTS '"'"'$1'"'"'@'"'"'%'"'"' IDENTIFIED BY '"'"'$1'"'"';
    GRANT ALL ON '$1'_testing.* TO '"'"'$1'"'"'@'"'"'%'"'"';
    
    
    <<"COMMENT"
    
    Optional (This displays the list of databases and should now include the newly created database): 
    show databases;
    
    COMMENT
    
    ";'
    
    # Change host in new Laravel app's .env to Laradock host 'mysql'
    sed -i -e "s/DB_HOST=127.0.0.1/DB_HOST=mysql/g" ~/Desktop/Dev/$1/.env
    
    # Change database in new Laravel app's .env to newly created database
    sed -i -e "s/DB_DATABASE=homestead/DB_DATABASE=$1_testing/g" "/c/Users/Michael Berry/Desktop/Dev/$1/.env"
    
    # Change user in new Laravel app's .env to newly created user
    sed -i -e "s/DB_USERNAME=homestead/DB_USERNAME=$1/g" "/c/Users/Michael Berry/Desktop/Dev/$1/.env"
    
    
    <<"COMMENT"
    
    If you use IntelliJ or one of their other applications (PHPStorm, WebStorm, etc.), 
    this will open the new Laravel app as a new project. If 1st @param's directory
    exists, then proceed to open in IntelliJ.
    
    COMMENT
    
    if [ -d "$1" ]; then
        echo "Opening IntelliJ project for $1"
        idea ~/Desktop/Dev/$1
    fi
fi
}

<<"COMMENT"

For the deletion and removal of a project from local files, Github and database.

@param string project-name
@param string Github Personal Access Token with delete_repo scope

Example:
setup todo 0987654321poiuytrewq

COMMENT

# If 2nd parameter is empty and doesn't equal 'ng', then we need a Github token
takedown(){
if [ -z "$2" ] && [ "$2" != "ng" ]; then
    echo "Please enter your Github delete authorization token."
else
    # cd to dev location
    dev
    
    # If the project directory exists, then...
    if [ -d "$1" ]; then
        echo "The directory $1 exists."
        
        # Delete the files...
        rm -rf $1
        
        # If a Github repo should be deleted, delete the repo...
        if [ "$2" != "ng" ]; then
          curl -X DELETE -H "Authorization: token $2" https://api.github.com/repos/michaeljberry/$1
        fi

        # cd to laradock folder
        cd ~/Desktop/Dev/laradock
        
        <<"COMMENT" 
    
          Windows Git Bash users must include 'winpty' at beginning to create sub-shell
          Exports MySQL password into mysql shell
          Logins as 'root' user
          In MySQL:
            Executes commands to delete the database
            Executes command to delete the user
      
        COMMENT
    
        winpty docker-compose exec mysql sh -c 'export MYSQL_PWD="$MYSQL_ROOT_PASSWORD"; mysql -uroot --execute "
        DROP DATABASE IF EXISTS '$1'_testing;
        DROP USER IF EXISTS '"'"'$1'"'"';
        ";'
    else
        echo "The directory $1 doesn\'t exist"
    fi
fi
}
