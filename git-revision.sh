#!/bin/bash

## Repo https://gitlab.com/kyb/build-info-header
## Update with:
##   wget 'https://gitlab.com/kyb/build-info-header/raw/master/git-revision.sh?inline=false' -qO git-revision.sh  &&  chmod +x git-revision.sh

set -e

GIT=${GIT:=git}
#alias GIT="$GIT"

short=$($GIT rev-parse --short HEAD)
#SHORT=$( echo $short | tr a-z A-Z )
long=$($GIT rev-parse HEAD)  #git -C $GitRepo show-ref -h HEAD
count=$($GIT rev-list --count --first-parent ${BuildInfo_RevName:=HEAD})

dirty=`$GIT diff --quiet || echo DIRTY`  # $GIT diff --quiet || dirty="DIRTY"
_dirty=${dirty:+-$dirty}  # Expands to nothing when $dirty is empty or undefined, and prepends '-' else.

tag=$($GIT tag --list --points-at HEAD)
tag_=${tag:+$tag$_dirty}

if [ -z $($GIT symbolic-ref HEAD -q) ]; then  # Check if HEAD is not a simbolic reference
	branch="DETACHED"
else
	branch=$($GIT rev-parse --abbrev-ref HEAD)  ## Show only the current branch, no parsing required
fi
branch_=$branch$_dirty   # ${branch:+$branch$_dirty}

refname=${tag+$branch}
format=${1:-'$refname-c$count-g$short$_dirty'}
revision=$( echo $(eval echo "$format") )   #"$refname-c$count-g$short$_dirty"

echo "$revision"
