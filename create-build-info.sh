#!/usr/bin/env bash
set -euo pipefail

## Example usage: 
##    ./create-build-info.sh build_info.h --format="`cat build_info.template.h`"
## or
##    ./create-build-info.sh build_info.h --format-file=build_info.template.h

TargetFile=$1; shift

D=$( dirname $( readlink -f "${BASH_SOURCE[0]}" ))  ## which was removed because of on our windows CI 'which' prints nothing if did not find in arg in PATH 

source "$D/git-rev-label.sh" "$@"

temppath=`mktemp`
echo "$revision" >$temppath

## Write to file only if there are changes
if diff --brief "$temppath" "$TargetFile" &>/dev/null  ;then
   echo >/dev/stderr "Nothing to change"
else
   cp "$temppath" "$TargetFile"  ||  {
      ret=$0
      echo Failed writing to "$TargetFile" >/dev/stderr
      exit $ret
   }
fi
