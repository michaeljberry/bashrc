source ~/env.sh
source ~/aliases.sh
source ~/aliases_docker.sh
source ~/aliases_git.sh
source ~/aliases_laravel.sh
source ~/functions_docker.sh
source ~/functions_git.sh
source ~/functions_laravel_package.sh

###
 # Navigate to root dev folder - optionally navigate to project
 #
 # @param folder
###
dev(){
    folder=$1
    printf "Navigating to Dev root folder... \n"

    cd ~
    cd $rootdevfolder

    if [ ! -z "$folder" ]; then
        navigateToProject $project
    fi
}

export XDEBUG_CONFIG="idekey=VSCODE"

###
 # Open project in Visual Studio Code and navigate to project folder
 #
 # @param project
###
openEditor(){
    project=$1

    dev

    if [ -d "$project" ]; then
        printf "Opening $project project in VSC \n"
        code $project

        cd $project
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

inputType(){
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

shouldFolderBeCreated(){
    shouldFolderBeCreated=$1

    if [ -z $shouldFolderBeCreated ]; then
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

createFolder(){
    folder=$1

    folder="$(inputIsSet "folder" "$folder")"
    mkdir $folder

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

createFolderIfNeeded(){
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

folderExists(){
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