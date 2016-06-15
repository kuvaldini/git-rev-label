#!/bin/sh

## Создаёт или редактирует файл build_info.h
## Переписывает файл только если что-то изменилось


filepath="$(git rev-parse --show-toplevel)/src/build_info.h"
#filepath=${filepath////\\}  ## Replace all / to \
temppath="${filepath}~"

## Header
echo -e "/**\n * This file was created automatically by script build_info.sh.\n * DO NOT EDIT! \n */\n" > $temppath

short=$(git rev-parse --short HEAD)
echo -e "#define BUILD_GIT_SHORT    \"$short\"" >> $temppath
long=$(git rev-parse HEAD)
echo -e "#define BUILD_GIT_LONG     \"$long\"" >> $temppath

## if result is not "" (working tree is not clean) then dirty.
[[ $(git status --porcelain) ]] && dirty="dirty" || dirty=""
[[ $dirty ]] && _dirty="-$dirty" || _dirty=""
echo -e "#define BUILD_GIT_DIRTY    \"$dirty\"" >> $temppath
echo -e "#define BUILD_GIT_DIRTY_   \"$_dirty\"" >> $temppath

## Записать тэг.
tag=$(git tag --list --points-at HEAD)
if [ $tag ] ; then
  if [ $dirty ] ; then
    tag=$tag-$dirty
  fi
fi
echo -e "#define BUILD_GIT_TAG      \"$tag\"" >> $temppath

## Записать ветку. 
branch=$(git branch --list --points-at HEAD | grep "^* .*")
branch=${branch:2}  ## Предполагается результат "* branch", убрать первые 2 символа.
if [ $branch ] ; then
  if [ $dirty ] ; then
    branch_=$branch-$dirty
  fi
fi
echo -e "#define BUILD_GIT_BRANCH   \"$branch_\"" >> $temppath

## Результирующие
echo -e "#define BUILD_GIT          BUILD_GIT_BRANCH\"(\"BUILD_GIT_SHORT\")\"BUILD_GIT_DIRTY" >> $temppath
echo -e "#define BUILD_GIT_         \"$branch($short)$_dirty\"" >> $temppath

# Копировать файл если есть изменения
if diff $temppath $filepath > /dev/null  ; then
  echo Nothing to change
else
  cp $temppath $filepath
fi

rm $temppath
