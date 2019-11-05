#!/bin/bash
## Laravel Package Functions
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
