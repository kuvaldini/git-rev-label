#!/usr/bin/env bash
set -eo pipefail

##ToDo may be use BUILD_ID=${CI_PIPELINE_IID}
#if test -x ./git-rev-label  &&  ./git-rev-label --version &>/dev/null ;then 
#   #BUILD_ID=$(./git-rev-label --version | sed -E 's#.*-b([0-9]+).*#\1#')
#   BUILD_ID=$(./git-rev-label --version | head -1 | sed -E 's#.*v[0-9]+\.[0-9]+\.([0-9]+).*#\1#')
#   let BUILD_ID++
#fi
BUILD_ID=${CI_PIPELINE_IID}
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