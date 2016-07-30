#!/bin/sh

## Создаёт или редактирует файл build_info.h
## Переписывает файл только если что-то изменилось, благодаря чему модули C, включающие build_info.h не будут перекопилированы.


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
if [ "$tag" ] ; then
  if [ "$dirty" ] ; then
    tag_=$tag
  else
    tag_=$tag-$dirty
  fi
fi
echo -e "#define BUILD_GIT_TAG      \"$tag_\"" >> $temppath

## Записать ветку. 
branch=$(git branch --list --points-at HEAD | grep "^* .*")
branch=${branch:2}  ## Предполагается результат "* branch", убрать первые 2 символа.
if [ "$branch" ] ; then
  if [ "$dirty" ] ; then
    branch_=$branch-$dirty
  else
    branch_=$branch
  fi
fi
echo -e "#define BUILD_GIT_BRANCH   \"$branch_\"" >> $temppath

## Результирующие
if [ "$tag" ] ; then
	echo -e "#define BUILD_GIT          BUILD_GIT_TAG\"(\"BUILD_GIT_SHORT\")\"BUILD_GIT_DIRTY_" >> $temppath
	echo -e "#define BUILD_GIT_         \"$tag($short)$_dirty\"" >> $temppath
else
	echo -e "#define BUILD_GIT          BUILD_GIT_BRANCH\"(\"BUILD_GIT_SHORT\")\"BUILD_GIT_DIRTY_" >> $temppath
	echo -e "#define BUILD_GIT_         \"$branch($short)$_dirty\"" >> $temppath
fi
echo -e "#define BUILD_INFO         \"Build \"__DATE__\" \"__TIME__\" Git \"BUILD_GIT" >> $temppath

## Копировать файл если есть изменения
if diff $temppath $filepath > /dev/null  ; then
  echo Nothing to change
else
  cp $temppath $filepath
fi

## Сообщить результат в консоль
echo "$branch($short)$_dirty"

rm $temppath
