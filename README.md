## This is an bash script that automates everything that I feel is needed for a new Laravel project.

**&ast;&ast;Credit for the inspiration for this script goes to Jeffrey Way.**

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
  - Include the scripts in [.bashrc][5] in your user profile `C:\Users\{username}\.bashrc` file. Be sure to change the necessary 
  - When Git Bash for Windows opens, it automatically imports your `C:\Users\{username}\.bashrc` file as aliases that are available for use within the Git Bash shell.
- [Laradock][6]
  - `C:\folder\where\you\installed\laradock\nginx\sites\laravel.conf` 
    - Allows for dynamic host configuration. Now after setting up a new Laravel project (`exampleapp`), you can navigate to `exampleapp.dev`.
  - `server_name ~^(?<project>.+)\.dev$;`
  - `root /var/www/$project/public;`

### How it functions

#### To setup a new Laravel project
1. Open Git Bash for Windows
2. Example: `setup {projectname} {Github PAT}||{ng}`
3. `setup todo 1234567890qwertyuiop`

This one command will setup these items:
- Laravel app called `todo` (@param1)
- New repo in your Github.com account - It will use the provided Github.com Personal Access Token (@param2) to authenticate
- New MySQL database (`todo_testing`)
- New MySQL user (`todo`)
- Grant all privileges to new user (`todo`)
- Configure `.env` with new `DB_HOST` (`mysql` - from Laradock), `DB_DATABASE` (`todo_testing`), `DB_USERNAME` (`todo`) information
- Open IntelliJ to new `todo` project

#### To teardown a Laravel project
1. Open Git Bash for Windows
2. Example: `teardown {projectname} {Gihub PAT}||{ng}`
3. `teardown todo 0987654321poiuytrewq`

This one command will:
- Delete Laravel app called `todo` (`@param1`)
- Delete Github.com repo on your account - It will use the provided Github.com Personal Access Token (`@param2`) to authenticate
- Drop MySQL database (`todo`)
- Drop MySQL user (`todo`)



[1]: http://laracasts.com
[2]: https://www.docker.com/docker-windows
[3]: http://mayakron.altervista.org/wikibase/show.php?id=AcrylicHome
[4]: https://git-scm.com/download/win
[5]: https://github.com/michaeljberry/bashrc/blob/master/.bashrc
[6]: http://laradock.io/
