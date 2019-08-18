#!/usr/bin/env bash

## Repo https://gitlab.com/kyb/git-rev-label
## Install and Update with:
##   curl 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' -Lf -o git-rev-label  &&  chmod +x git-rev-label
##   wget 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' -qO git-rev-label  &&  chmod +x git-rev-label
## To make this command work as git subcommand `git rev-label` create link to this script in PATH:
##   ln -s $PWD/git-rev-label.sh /usr/local/bin/git-rev-label
## Then use it
##   git rev-label
## or
##   git rev-label '$refname-c$count-g$short$_dirty'

set -euo pipefail

VERSION=000
VERSION_NPM=0.0.0


function echomsg               { echo $'\e[1;37m'"$@"$'\e[0m'; }
function echodbg  { >/dev/stderr echo $'\e[0;36m'"$@"$'\e[0m'; }
function echowarn { >/dev/stderr echo $'\e[0;33m'"$@"$'\e[0m'; }
function echoerr  { >/dev/stderr echo $'\e[0;31m'"$@"$'\e[0m'; }

function OnErr {  caller | { read lno file; echoerr ">ERR in $file:$lno" >&2; };  }
trap OnErr ERR

is_sourced(){
   [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

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


function --help {
   echo -n \
'Gives information about Git repository revision in format like '"'master-c73-gbbb6bec'"'.
Can fill template string or file with environment variables and information from Git. 
Useful to provide information about version of the program: branch, tag, commit hash, 
commits count, dirty status, date and time. One of the most useful things is count of 
commits, not taking into account merged branches - only first parent.

USAGE:
   git rev-label
   git rev-label [--help|-h|-?]
   git rev-label [--version|-V]
   git rev-label '"'"'$refname-c\$count-g\$short\$_dirty'"'"'
   git rev-label --format="`cat build_info.template.h`"
   git rev-label --format-file=build_info.template.h
   git rev-label --variables [--export]
   eval $( git rev-label --variables [--export] )

COMPLEX USE CASE:
 * Fill `build_info.template.h` with branch, tag, commit hash, commits count, dirty status. 
   Than include result header to access build information from code. 
   See https://gitlab.com/kyb/git-rev-label/blob/master/build_info.template.h and
   https://gitlab.com/kyb/git-rev-label/blob/master/create-build-info.sh

INSTALLATION:
   ./git-rev-label --install|--install-link [--install-dir=/usr/local/bin]

UPDATE:
   git rev-label --update

More info at https://gitlab.com/kyb/git-rev-label
'
}
function --version {
   echo "git-rev-label v$VERSION_NPM 
   $VERSION
   https://gitlab.com/kyb/git-rev-label"
}
-V(){ echo "git-rev-label v$VERSION_NPM"; }
function --rev-label {
   echo "$VERSION"
}
--rev(){ --rev-label "$@"; }
--version-npm(){ echo $VERSION_NPM; }
--npm-version(){ --version-npm "$@"; }

function --variables {
   var_is_unset_or_empty export  &&  export=  ||  export=export
   echo ${export} GIT=\'"$GIT"\'
   echo ${export} commit=\'"$commit"\'
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
   echo ${export} tag_dirty=\'"$tag_dirty"\'
   echo ${export} branch=\'"$branch"\'
   echo ${export} branch_dirty=\'"$branch_dirty"\'
   echo ${export} refname=\'"$refname"\'
   echo ${export} format=\'"$format"\'
   var_is_set revision  &&  echo ${export} revision=\'"$revision"\'
}
-v(){ --variables "$@"; }
--vars(){ --variables "$@"; }
--export-variables(){
   export=1 --variables "$@"
}

## Unset variables from environment
unset format install_dir export

while [[ $# > 0 ]] ;do
   case $1 in 
      --help|-help|help|-h|\?|-\?)  
         --help
         exit
         ;;
      --version|-V|--version-npm|--npm-version|--rev-label|--rev)
         $1
         exit
         ;;
      --variables|--vars|-v|--export-variables|--install-link|--install|--install-script|--update|--update-script)  
         var_is_set action  && echowarn "!!! action already set to '$action'. Overriding"
         action=$1 
         ;;
      --install-dir=*)
         var_is_set install_dir  && echowarn "!!! install_dir already set to '$install_dir'. Overriding"
         install_dir="${1##--install-dir=}"
         ;;
      --force|-f)
         force=f
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
      --format-from=*)  ## Alias to --format-file
         var_is_set format  && echowarn "!!! format already set to '$format'. Overriding"
         format="$( cat ${1##--format-from=} )"
         ;;
      -x|--trace|--xtrace)
         set -x;
         ;;
      +x|--no-trace|--no-xtrace)
         set +x;
         ;;
      -*|--*) echowarn "!!! Unknown option $1";;
      *)
         var_is_set format  && echowarn "!!! format already set to '$format'. Overriding"
         format="$1"
         ;;
   esac
   shift
done

########### MAINTENANCE ACTIONS ###########
if var_is_set_not_empty action ;then
   case "$action" in
      --update|--update-script)
         TEMP=`mktemp`
         curl 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' -LsSf -o $TEMP
         chmod +x $TEMP
         if diff -q "${BASH_SOURCE[0]}" $TEMP &>/dev/null ;then
            echomsg "Already up to date."
            rm -f $TEMP
            exit
         else
            exec mv $TEMP $(readlink -f "${BASH_SOURCE[0]}")
         fi
         ;;
      --install-link)
         install_dir=${install_dir:='/usr/local/bin'}
         exec ln -s ${force:+-f} $(readlink -f "${BASH_SOURCE[0]}") "$install_dir/git-rev-label"
         ;;
      --install|--install-script)
         install_dir=${install_dir:='/usr/local/bin'}
         install_dir=$(eval echo $install_dir)
         cp "${BASH_SOURCE[0]}" "$install_dir/git-rev-label"
         chmod +x "$install_dir/git-rev-label"
         exit
         ;;
   esac
fi

########################################################
########## CHECK CONFIGURATION VARIABLES ###############
if var_is_set_not_empty export  &&  [[ ${action:-default_action} != --variables ]] ;then
   echowarn "!!! --[-no]export is only meaningful with --variables."
fi

format=${format:='$refname-c$count-g$short$_DIRTY'}
if test -z "$format" ;then
   echowarn "!!! format is empty."
fi

#####################################################
########## SET git rev-label VARIABLES ###############
######### Quintessence (quīnta essentia) ############

GIT=${GIT:=git}
#alias GIT="$GIT"

commit=$($GIT rev-parse --short HEAD)
short=$commit
SHORT=$( echo $short | tr a-z A-Z )
long=$($GIT rev-parse HEAD)  #$GIT show-ref -h HEAD
LONG=$( echo $long | tr a-z A-Z )
count=$($GIT rev-list --count --first-parent HEAD )
COUNT=$($GIT rev-list --count                HEAD )

dirty=`test -z "$($GIT status --porcelain)" || echo dirty`  # dirty=`$GIT diff --quiet || echo dirty` does not care about untracked
_dirty=${dirty:+-$dirty}  # Expands to nothing when $dirty is empty or undefined, and prepends '-' else.
DIRTY=$( echo $dirty | tr a-z A-Z )
_DIRTY=$( echo $_dirty | tr a-z A-Z )

tag="$($GIT tag --list --points-at HEAD)"
tag_dirty="${tag:+$tag$_dirty}"

if [ -z $($GIT symbolic-ref HEAD -q) ]; then  # Check if HEAD is not a simbolic reference
   branch="DETACHED"
   refname="${tag:-$branch}"
else
   branch=$($GIT rev-parse --abbrev-ref HEAD)  ## Show only the current branch, no parsing required
   refname="$branch"
fi
branch_dirty="$branch$_dirty"
refname_dirty="$refname$_dirty"

format=${format:='$refname-c$count-g$short$_DIRTY'}
eval "`export=export --variables`"
revision=$( echo "$format" | perl -pe 's|\$([A-Za-z_]+)|defined $ENV{$1} ? $ENV{$1} : $&|eg' )

########################################################
########## Handle non-maintenance actions ##############

function default_action {
   echo "$revision"
}
if ! is_sourced ;then
   ${action:-default_action}  # do action if set and __main__ if not
fi
