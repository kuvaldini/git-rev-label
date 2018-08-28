#!/bin/bash

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

#revision="${tag+$branch}-c$count($short)$_dirty"
revision="${tag+$branch}-c$count-$short$_dirty"

echo "$revision"
