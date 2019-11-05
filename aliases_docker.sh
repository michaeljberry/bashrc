#!/bin/bash
## Docker Aliases
alias dps="docker ps"
alias dcb="docker-compose build"
alias dcbw="docker-compose build workspace"
alias watchlog="docker logs -f laradock_php-fpm_1"
alias reloadphp="docker-compose up -d --force-recreate --build nginx"
alias drmc='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images -aq)'
alias di='docker images'
alias dsdf='docker system df'
