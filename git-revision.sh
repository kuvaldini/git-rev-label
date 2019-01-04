#!/bin/bash

## Repo https://gitlab.com/kyb/build-info-header
## Update with:
##   wget 'https://gitlab.com/kyb/build-info-header/raw/master/git-revision.sh?inline=false' -qO git-revision.sh  &&  chmod +x git-revision.sh
## To make this command work as git subcommand `git revision` create link to this script in PATH:
##   ln -s $PWD/git-revision.sh /usr/local/bin/git-revision
## Then use it
##   git revision
## or
##   git revision '$refname-c$count-g$short$_dirty'

set -e

GIT=${GIT:=git}
#alias GIT="$GIT"

short=$($GIT rev-parse --short HEAD)
SHORT=$( echo $short | tr a-z A-Z )
long=$($GIT rev-parse HEAD)  #git -C $GitRepo show-ref -h HEAD
LONG=$( echo $long | tr a-z A-Z )
count=$($GIT rev-list --count --first-parent ${BuildInfo_RevName:=HEAD})

dirty=`$GIT diff --quiet || echo dirty`  # $GIT diff --quiet || dirty="dirty"
_dirty=${dirty:+-$dirty}  # Expands to nothing when $dirty is empty or undefined, and prepends '-' else.
DIRTY=$( echo $dirty | tr a-z A-Z )
_DIRTY=$( echo $_dirty | tr a-z A-Z )

tag=$($GIT tag --list --points-at HEAD)
tag_=${tag:+$tag$_dirty}

if [ -z $($GIT symbolic-ref HEAD -q) ]; then  # Check if HEAD is not a simbolic reference
	branch="DETACHED"
else
	branch=$($GIT rev-parse --abbrev-ref HEAD)  ## Show only the current branch, no parsing required
fi
branch_=$branch$_dirty   # ${branch:+$branch$_dirty}

refname=${tag+$branch}
format=${1:-'$refname-c$count-g$short$_DIRTY'}
revision=$( echo $(eval echo "$format") )   #"$refname-c$count-g$short$_dirty"

echo "$revision"
