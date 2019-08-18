#!/usr/bin/env bash
set -eo pipefail

#BUILD_ID=${CI_PIPELINE_IID}  ## Do not use since CI_PIPELINE_IID provides unique job number inside project, because 
if test -x ./git-rev-label  &&  ./git-rev-label --version &>/dev/null ;then 
   BUILD_ID=$(./git-rev-label --rev-label | sed -E 's#.*-b([0-9]+).*#\1#')  ## parse from 'master-c22-g234dca-b31'
   #BUILD_ID=$(./git-rev-label --version-npm | sed -E 's#.*v[0-9]+\.[0-9]+\.([0-9]+).*#\1#')  ## parse from '1.2.34'
   let BUILD_ID++ || {
      echo >&2 'WARN: Failed to detect BUILD_ID. Count from 1.'
   }
fi
BUILD_ID=${BUILD_ID:=1}  ## fall back to 1

sed -f <( cat<<'END'
{
   /^source \$mydir/ {
      a
      a ### BEGIN utils.bash ###
      r utils.bash
      a ### END utils.bash ###
      a 
      d
   }
}
END
) git-rev-label.sh >git-rev-label

VERSION="$(git rev-label --format='$refname-c$count-g$short'-b$BUILD_ID\$_dirty )"
sed -i "s#VERSION=000#VERSION=$VERSION#" git-rev-label

VER_MAJ=1; if test "$CI_COMMIT_REF_NAME" = master ;then VER_MAJ=1; fi 
#VERSION_NPM="$(echo $VERSION | sed -nE 's#.*c([0-9]+)-g(.[0-9a-f]+)-b([0-9]+).*#'$VER_MAJ'.\1.\3#p' )"
VERSION_NPM="$(git rev-label --format=$VER_MAJ.'$count'.$BUILD_ID )"
sed -i "s#VERSION_NPM=0.0.0#VERSION_NPM=$VERSION_NPM#" git-rev-label

chmod +x git-rev-label
