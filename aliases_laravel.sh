#!/bin/bash
## Laravel
alias pa="php artisan"
alias pacac="php artisan cache:clear"
alias pacaf="php artisan cache:forget"
alias pacat="php artisan cache:table"
alias pacoc="php artisan config:cache"
alias pacocl="php artisan config:clear"
alias padbs="php artisan db:seed"
alias padown="php artisan down"
alias paeg="php artisan event:generate"
alias pakg="php artisan key:generate"
alias pama="php artisan make"
alias pamaa="php artisan make:auth"
alias pamaco="php artisan make:command"
alias pamac="php artisan make:controller"
alias pamacr="php artisan make:controller -r"
alias pamaev="php artisan make:event"
alias pamaf="php artisan make:factory"
alias pamaj="php artisan make:job"
alias pamal="php artisan make:listener"
alias pamama="php artisan make:mail"
alias pamamid="php artisan make:middleware"
alias pamami="php artisan make:migration"
alias pamamo="php artisan make:model"         #Use '/' to place model in sub-folder
alias pamamoc="php artisan make:model -c"     #controller
alias pamamorc="php artisan make:model -rc"   #resource controller
alias pamamom="php artisan make:model -m"     #migration
alias pamamomc="php artisan make:model -mc"   #migration + controller
alias pamamomrc="php artisan make:model -mrc" #migration + resource controller
alias paman="php artisan make:notification"
alias pamapo="php artisan make:policy"
alias pamapr="php artisan make:provider"
alias pamarq="php artisan make:request"
alias pamars="php artisan make:resource"
alias pamaru="php artisan make:rule"
alias pamas="php artisan make:seeder"
alias pamat="php artisan make:test"
alias pami="php artisan migrate"
alias pamif="php artisan migrate:fresh"
alias pamir="php artisan migrate:refresh"
alias pamirs="php artisan migrate:refresh --seed"
alias pamire="php artisan migrate:reset"
alias pamires="php artisan migrate:reset && php artisan migrate --seed"
alias pamiro="php artisan migrate:rollback"
alias pamis="php artisan migrate:status"
alias pant="php artisan notifications:table"
alias paqf="php artisan queue:failed"
alias paqft="php artisan queue:failed-table"
alias paqfl="php artisan queue:flush"
alias paqfo="php artisan queue:forget"
alias paql="php artisan queue:listen"
alias paqre="php artisan queue:restart"
alias paqr="php artisan queue:retry"
alias paqt="php artisan queue:table"
alias paqw="php artisan queue:work"
alias parca="php artisan route:cache"
alias parcl="php artisan route:clear"
alias parl="php artisan route:list"
alias pascr="php artisan schedule:run"
alias pase="php artisan session"
alias paset="php artisan session:table"
alias pastl="php artisan storage:link"
alias pat="php artisan tinker"
alias paup="php artisan up"
alias pavp="php artisan vendor:publish"
alias pavpf="php artisan vendor:publish --tag=public --force"

alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'
