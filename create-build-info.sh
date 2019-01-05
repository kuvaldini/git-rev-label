#!/bin/bash
set -euo pipefail

## Example usage: 
##    TargetFile=123.h ./create-build-info.sh --format="`cat build_info.template.h`"

D=$( dirname $( readlink -f $( which "${BASH_SOURCE[0]}" )))

source "$D/git-revision.sh" "$@"

temppath=`mktemp`
echo "$revision" >$temppath

## Копировать файл если есть изменения. &>/dev/null для вывода stdout и stderr в никуда.
if diff --brief "$temppath" "$TargetFile" &>/dev/null  ;then
   echo >/dev/stderr "Nothing to change"
else
   cp "$temppath" "$TargetFile"  ||  {
      ret=$0
      echo Failed writing to "$TargetFile" >/dev/stderr
      exit $ret
   }
fi
