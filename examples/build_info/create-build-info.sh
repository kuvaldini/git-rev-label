#!/usr/bin/env bash
set -euo pipefail

## Write to file only if there are changes
## Example usage: 
##    ./create-build-info.sh build_info.h --format="`cat build_info.template.h`"
## or
##    ./create-build-info.sh build_info.h --format-file=build_info.template.h

TargetFile=$1; shift

D=$( dirname $( readlink -f "${BASH_SOURCE[0]}" ))

temppath=`mktemp`
"$D/git-rev-label.sh" "$@" >$temppath
diff --brief "$temppath" "$TargetFile" &>/dev/null  \
   && echo >/dev/stderr "$TargetFile is up to date"
   || cp "$temppath" "$TargetFile"
