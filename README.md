## This is a bash script that automates everything that I feel is needed for a new Laravel project.

**&ast;&ast;The inspiration to build this script came from trying to keep up with [Jeffrey Way][7]'s tutorials on [Laracasts.com][1].&ast;&ast;**

**&ast;&ast;This is for local development only. DO NOT USE IN PRODUCTION ENVIRONMENT.&ast;&ast;**

### Explanation for why
**TL;DR**
**Because it made a lot of sense**

On a normal day, during my normal routine, I was listening to Jeffrey Way explain Laravel nuances on [Laracasts.com][1] and he said something that finally hit me, and I'm paraphrasing:

> People wonder how to get really good at Laravel; it's by doing this over and over and over. Repetition creates muscle memory.

I realized that for many of his tutorials, he uses a fresh install of Laravel and then he builds up his project. What I dreaded about following along with his tutorials was setting up a fresh install of Laravel for each series/tutorial/etc. There just seemed like a lot of moving parts and my memory isn't very good. On top of that, I hadn't taken the time to create a dreaded to-do list to document all the steps, because frankly, I still had to execute all of those commands by hand. 

I finally got up the courage to write a bash script to automate it all. After all, though I knew many terminal commands for &ast;nix systems, I hadn't ever really tied them together in one script. But it dawned on me that if I created this script, then with arguments, I could control the exceptions as needed. Since a fresh install of Laravel is pretty standard, I could, for the most part, keep the upkeep of such a script to a minimum.

This script will now allow me to, with very minimal effort, spin up a fresh instance of Laravel with all the needed configurations and hopefully help me on my path to be an awesome Laravel developer. Hey, I can dream, right?!

### My setup
- Windows 10 Education
- Hyper V (enabled in BIOS)
- [Docker for Windows][2]
- [Acrylic DNS Proxy][3] - Allows for dynamic host configuration as Windows' normal `C:\Windows\System32\drivers\etc\hosts` file doesn't allow dynamic hosts.
  - `AcrylicHosts.txt` - At the very bottom:
  - 127.0.0.1 &ast;.dev
- [Git Bash for Windows][4]
  - Save `laravelsetup.sh` in `C:\Users\{username}`.
  - Add the line `source ~/laravelsetup.sh` to [.bashrc][5] in your user folder `C:\Users\{username}\`. Be sure to change the necessary variables in `laravelsetup.sh`:
      - `devfolder`
      - GitHub `{username}`
  - When Git Bash for Windows opens, it automatically imports your `C:\Users\{username}\.bashrc` file as aliases that are available for use within the Git Bash shell.
- [Laradock][6]
  - `C:\folder\where\you\installed\laradock\nginx\sites\laravel.conf` 
    - Allows for dynamic host configuration. Now after setting up a new Laravel project (`exampleapp`), you can navigate to `exampleapp.dev`.
  - `server_name ~^(?<project>.+)\.dev$;`
  - `root /var/www/$project/public;`

### How it functions

#### To setup a new Laravel project
1. Open Git Bash for Windows
2. Example: `setup @param1 @param2 @param3`
    1. `@param1` - projectname
    2. `@param2` - **Options as follows:**
        1. GitHub Personal Access Token - Must have full repo scope authorization.
        2. `ng` - This will NOT intialize git or create a repo on GitHub.com. Stands for 'No Git'
    3. `@param3` - **Options as follows:** (Include as a single, undelimited string)
        1. `p` - Indicates a private GitHub repo should be created.
        2. `t` - Setup testing. These are the settings that are setup with this argument:
            1. `phpunit.xml` - Add these lines:
                1. `<env name="DB_CONNECTION" value="sqlite"/>`
                2. `<env name="DB_DATABASE" value=":memory:"/>`
            2. `tests/Utilities/functions.php` - These are helper functions
                
                1. 
                
                ```php
                function create(\$class, \$attributes = [], \$times = null)
                {
                    return factory(\$class, \$times)->create(\$attributes);
                }
                
                function make(\$class, \$attributes = [], \$times = null)
                {
                    return factory(\$class, \$times)->make(\$attributes);
                }
                ```
                
            3. `composer.json` - Edit line and append line
                
                1. 
                
                ```json
                "autoload-dev": {
                    "psr-4": {
                        "Tests\\": "tests/"
                    }, // Line edited
                    "files": ["tests/utilities/functions.php"] // Line added
                },
                ```
                
3. `setup todo 1234567890qwertyuiop pt`

This one command will setup these items:
- Laravel app called `todo` (`@param1`)
- New *private* repo in your GitHub.com account - It will use the provided GitHub.com Personal Access Token (`@param2`) to authenticate
- New MySQL database (`todo_testing`)
- New MySQL user (`todo`)
- Grant all privileges to new user (`todo`)
- Configure `.env` with new `DB_HOST` (`mysql` - from Laradock), `DB_DATABASE` (`todo_testing`), `DB_USERNAME` (`todo`) information
- Setup common testing configurations
- Open IntelliJ to new `todo` project

#### To teardown a Laravel project
1. Open Git Bash for Windows
2. Example: `teardown @param1 @param2`
    1. `@param1` - projectname
    2. `@param2` - **Options as follows:**
        1. GitHub Personal Access Token - Must have `delete_repo` scope authorization.
        2. `ng` - This will NOT delete the repo on GitHub.com. Stands for 'No GitHub'
3. `teardown todo 0987654321poiuytrewq`

This one command will:
- Delete Laravel app called `todo` (`@param1`)
- Delete GitHub.com repo on your account - It will use the provided GitHub.com Personal Access Token (`@param2`) to authenticate
- Drop MySQL database (`todo`)
- Drop MySQL user (`todo`)



[1]: http://laracasts.com
[2]: https://www.docker.com/docker-windows
[3]: http://mayakron.altervista.org/wikibase/show.php?id=AcrylicHome
[4]: https://git-scm.com/download/win
[5]: https://github.com/michaeljberry/bashrc/blob/master/.bashrc
[6]: http://laradock.io/
[7]: https://github.com/JeffreyWay
