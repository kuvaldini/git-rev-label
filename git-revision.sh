#!/usr/bin/env bash

## Repo https://gitlab.com/kyb/build-info-header
## Update with:
##   wget 'https://gitlab.com/kyb/build-info-header/raw/master/git-revision.sh?inline=false' -qO git-revision.sh  &&  chmod +x git-revision.sh
## To make this command work as git subcommand `git revision` create link to this script in PATH:
##   ln -s $PWD/git-revision.sh /usr/local/bin/git-revision
## Then use it
##   git revision
## or
##   git revision '$refname-c$count-g$short$_dirty'

set -euo pipefail

function echomsg               { echo $'\e[1;37m'"$@"$'\e[0m'; }
function echodbg  { >/dev/stderr echo $'\e[0;36m'"$@"$'\e[0m'; }
function echowarn { >/dev/stderr echo $'\e[0;33m'"$@"$'\e[0m'; }
function echoerr  { >/dev/stderr echo $'\e[0;31m'"$@"$'\e[0m'; }

function OnErr {  caller | { read lno file; echoerr ">ERR in $file:$lno" >&2; };  }
trap OnErr ERR

is_sourced(){
   [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}


function --help {
   echo \
"Repo https://gitlab.com/kyb/build-info-header
Update with:
  wget 'https://gitlab.com/kyb/build-info-header/raw/master/git-revision.sh?inline=false' -qO git-revision.sh  &&  chmod +x git-revision.sh
To make this command work as git subcommand \`git revision\` create link to this script in PATH:
  ln -s \$PWD/git-revision.sh /usr/local/bin/git-revision
Then use it as one of
  git revision
  git revision [--help|-h|-?]
  git revision [--version|-V]
  git revision '\$refname-c\$count-g\$short\$_dirty'"
  git revision --format="`cat build_info.template.h`"
  git revision --variables [--export]
  eval $( git revision --variables [--export] )
}
function --version {
   echo "git-revision v1.0 by kyb@gitlab.com"
}
-V(){ --version "$@"; }

function --variables {
   var_is_unset export  &&  export=  ||  export=export
   echo ${export} GIT=\'"$GIT"\'
   echo ${export} short=\'"$short"\'
   echo ${export} SHORT=\'"$SHORT"\'
   echo ${export} long=\'"$long"\'
   echo ${export} LONG=\'"$LONG"\'
   echo ${export} count=\'"$count"\'
   echo ${export} COUNT=\'"$COUNT"\'
   echo ${export} dirty=\'"$dirty"\'
   echo ${export} _dirty=\'"$_dirty"\'
   echo ${export} DIRTY=\'"$DIRTY"\'
   echo ${export} _DIRTY=\'"$_DIRTY"\'
   echo ${export} tag=\'"$tag"\'
   echo ${export} tag_=\'"$tag_"\'
   echo ${export} branch=\'"$branch"\'
   echo ${export} branch_=\'"$branch_"\'
   echo ${export} refname=\'"$refname"\'
   echo ${export} format=\'"$format"\'
   #echo ${export} revision=\'"$revision"\'
}
-v(){ --variables "$@"; }

var_is_set(){
   declare -rn var=$1
   ! test -z ${var+x}
}
var_is_set_not_empty(){
   declare -rn var=$1
   ! test -z ${var:+x}
}
var_is_unset(){
   declare -rn var=$1
   test -z ${var+x}
}
var_is_unset_or_empty(){
   declare -rn var=$1
   test -z ${var:+x}
}

## Set default value, and overwrite variable from environment
format='$refname-c$count-g$short$_DIRTY'

while [[ $# > 0 ]] ;do
   case $1 in 
      --help|-help|help|-h|\?|-\?)  
         --help
         exit 0
         ;;
      --version|-V)
         --version
         exit 0
         ;;
      --update-script)
         exec bash -c "wget 'https://gitlab.com/kyb/build-info-header/raw/master/git-revision.sh?inline=false' -qO '${BASH_SOURCE[0]}'  &&  chmod +x '${BASH_SOURCE[0]}' "
         ;;
      --variables|-v)  
         var_is_set action  && echowarn "!!! action already set to '$action'. Overriding"
         action=$1 
         ;;
      --export|-e)  
         var_is_set export  && echowarn "!!! export already set to '$export'. Overriding"
         export=export
         ;;
      --no-export)  
         var_is_set export  && echowarn "!!! export already set to '$export'. Overriding"
         export=
         ;;
      --format=*)
         var_is_set format  && echowarn "!!! format already set to '$format'. Overriding"
         format="${1##--format=}"
         ;;
      --format-file=*)
         var_is_set format  && echowarn "!!! format already set to '$format'. Overriding"
         format="$( cat ${1##--format-file=} )"
         ;;
      -*|--*) echowarn "!!! Unknown option $1";;
      *)
         var_is_set format  && echowarn "!!! format already set to '$format'. Overriding"
         format="$1"
         ;;
   esac
   shift
done
if var_is_set_not_empty export  &&  [[ ${action:-default_action} != --variables ]] ;then
  echowarn "!!! --[-no]export is only meaningful with --variables."
fi
if test -z "$format" ;then
   echowarn "!!! format is empty."
fi

GIT=${GIT:=git}
#alias GIT="$GIT"

short=$($GIT rev-parse --short HEAD)
SHORT=$( echo $short | tr a-z A-Z )
long=$($GIT rev-parse HEAD)  #$GIT show-ref -h HEAD
LONG=$( echo $long | tr a-z A-Z )
count=$($GIT rev-list --count --first-parent ${BuildInfo_RevName:=HEAD})
COUNT=$($GIT rev-list --count                ${BuildInfo_RevName:=HEAD})

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
format=${format:='$refname-c$count-g$short$_DIRTY'}
eval "`export=export --variables`"
revision=$(  echo "$format" | perl -pe 's|\$([A-Za-z_]+)|$ENV{$1}|g' )   #"$refname-c$count-g$short$_dirty"


function default_action {
   echo "$revision"
}
if ! is_sourced ;then
   ${action:-default_action}  # do action if set and __main__ if not
fi
