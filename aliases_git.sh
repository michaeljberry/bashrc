## Git Aliases
alias ga="git add"
alias gaa="git add ."
alias gb="git branch"
alias gbd="git branch -d"
alias gbfd="git branch -D"
alias gc="git commit -m"
alias gd="git --no-pager diff" # -w <- Shows meaningful changes only
alias gdc="git diff --cached" # Show changes in staging area
alias gf="git fetch"
alias gi="git init"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gm="git merge"
alias go="git checkout"
alias gob="git checkout -b"
alias goverview="git log --all --oneline --no-merges" # --since='2 weeks' #Shows what everyone has been doing
alias gp="git push"
alias gpt="git push --tags"
alias gpl="git pull"
alias gpraise="git blame" # -L5,10 #<file_name>
alias gr="git reset"
alias grecap="git log --all --oneline --no-merges --author=" #<your email address>
alias grecent="git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format=\"%(refname:short)\""
alias grev="git reset --hard && git clean -df"
alias grh="git reset --hard"
alias grs="git reset --soft"
alias grb="git rebase master"
alias grm="git rm --cached"
alias gs="git status"
alias gst="git stash"
alias gsta="git stash apply"
alias gstats="git shortlog -sn" #--since='10 weeks' --until='2 weeks'
alias gstl="git stash list"
alias gstp="git stash pop"
alias gstreamup="git log --oneline --no-merges .." #<remote>/<branch> <- Review what you're about to pull
alias gstreamdown="git log --oneline --no-merges " #<remote>/<branch>.. <- Review what you're about to push
alias gtoday="git log --since=00:00:00 --all --no-merges --oneline --author=" #<your email address> <- Today's work
alias getbranchname="git rev-parse --abbrev-ref HEAD"