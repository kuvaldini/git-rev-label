#!/usr/bin/env bash
set -eo pipefail

current_branch(){
   git rev-parse --abbrev-ref HEAD
}

if test "`current_branch`" == master ;then
   VER_MAJ=${VER_MAJ:=2}
else
   VER_MAJ=${VER_MAJ:=0}
fi

#BUILD_ID=${CI_PIPELINE_IID}  ## Do not use since CI_PIPELINE_IID provides unique job number inside project, because 
if test -x ./git-rev-label  &&  ./git-rev-label --version &>/dev/null ;then 
   #BUILD_ID=$(./git-rev-label --rev-label | sed -E 's#.*-b([0-9]+).*#\1#')  ## parse from 'master-c22-g234dca-b31'
   #BUILD_ID=$(./git-rev-label --version-npm | sed -E 's#[0-9]+\.[0-9]+\.([0-9]+).*#\1#')  ## parse from '1.2.34'
   prev_ver=( $(./git-rev-label --version-npm | sed 's#\.# #g' ) )
   prev_ver_maj=${prev_ver[0]} prev_ver_min=${prev_ver[1]} BUILD_ID=${prev_ver[2]}
   if (( $VER_MAJ > $prev_ver_maj )) ;then
      BUILD_ID=1
   else
      let BUILD_ID++ || {
         echo >&2 'WARN: Failed to detect BUILD_ID. Count from 1.'
      }
   fi
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

VERSION="$(git rev-label --format='$refname-c$count-g$short'-b$BUILD_ID\$_dirty --from=master-c129-ge3d379f-b115 )"
echo $VERSION
sed -i "s#VERSION=000#VERSION=$VERSION#" git-rev-label

#VERSION_NPM="$(echo $VERSION | sed -nE 's#.*c([0-9]+)-g(.[0-9a-f]+)-b([0-9]+).*#'$VER_MAJ'.\1.\3#p' )"
VERSION_NPM="$(git rev-label --format=$VER_MAJ.\$count.$BUILD_ID --from=master-c129-ge3d379f-b115 )"
sed -i "s#VERSION_NPM=0.0.0#VERSION_NPM=$VERSION_NPM#" git-rev-label

chmod +x git-rev-label
