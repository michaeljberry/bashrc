#!/bin/bash
## Common Used Aliases
alias ll="ls -lah"
alias h="cd $home"
alias c="clear"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias hi="history"
alias j="jobs"
alias e='exit'
alias cla="clear && ls -l"
alias cll="clear && ls -la"
alias cls="clear && ls"
alias ea="vi ~/aliases"
alias reload="source ~/${BASHFILE}"

## Composer
alias cu="composer update"
alias ci="composer install"
alias cda="composer dump-autoload"
alias cdao="composer dump-autoload -o"

## Other
alias phpspec="vendor/bin/phpspec"

## PHPUnit
alias phpunit="vendor/bin/phpunit"
alias pu="phpunit"
alias puf="phpunit --filter"
alias pud="phpunit --debug"
puts(){
    testsuite=$1
    pu --testsuite=$1
}
alias puxi="phpunit --exclude-group integration"

## Jest
#alias jest="yarn test"
