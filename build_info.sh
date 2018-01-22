#!/bin/sh

# contains(string, substring)
#
# Returns 0 if the specified string contains the specified substring,
# otherwise returns 1.
contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}


## Создаёт или редактирует файл build_info.h
## Переписывает файл только если что-то изменилось, благодаря чему модули C/C++, включающие build_info.h не будут перекопилированы.
## TODO Ignore new submodules. Актуально при возврате на предыдущие коммиты, чтоб не числились как Dirty
## TODO Стоит ли писать detached?

scriptName=$(basename "${0}")
if [[ "$1" == "-h" ]]; then
	echo -e "Usage:\n"\
		 " $scriptName [GitRepo] [TargetFile] \n" \
		 "  GitRepo     Any path under Git VCS. If not specified, uses current folder \n" \
		 "  TargetFile  Optional, default is $GitRepoTopLevelPath/src/build_info.h "
	exit 1
fi
## Set GitRepo
if [[ -n "$1" ]]; then
	GitRepo=$1
	if [ ! -d "$GitRepo" ]; then
		echo "GitRepo $GitRepo is not a directory"
		exit 1
	fi
else
	GitRepo=$(pwd)
fi
## Check if $GitRepo is inside Git repository  ###--is-inside-git-dir
$(git -C "$GitRepo" rev-parse)
if [ $? != 0 ]; then 
	echo "GitRepo \"${GitRepo}\" is not valid"
	exit 1;
fi

## Set TargetFile
if [ -n "$2" ]; then
	TargetFile=$2
else
	## Default TargetFile. 
	GitRepoTopLevelPath=$(git -C "$GitRepo" rev-parse --show-toplevel)
	contains "$GitRepoTopLevelPath" "fatal"  &&  \
			echo "$GitRepoTopLevelPath"  &&  exit
	TargetFile="$GitRepoTopLevelPath/src/build_info.h"
fi

#DEBUG_SCRIPT=1
if (( $DEBUG_SCRIPT )); then
	echo GitRepo: $GitRepo
	echo GitRepoTopLevelPath: $GitRepoTopLevelPath
	echo TargetFile: $TargetFile
fi

temppath="$(mktemp -p /dev/shm/)"  ## Файл по идее в ОЗУ http://unix.stackexchange.com/a/188537/156608

short=$(git -C "$GitRepo" rev-parse --short HEAD)
long=$(git -C "$GitRepo" rev-parse HEAD)  #git -C $GitRepo show-ref -h HEAD
count=$(git -C "$GitRepo" rev-list --count HEAD)
[[ $(git -C "$GitRepo" status --porcelain) ]] && dirty="dirty" || dirty=""
[[ $dirty ]] && _dirty="-$dirty" || _dirty=""

## Записать тэг.
tag=$(git -C "$GitRepo" tag --list --points-at HEAD)
if [ "$tag" ] ; then
  if [ "$dirty" ] ; then
    tag_=$tag
  else
    tag_=$tag-$dirty
  fi
fi

## Записать ветку. 
## Check detached
if [ -z $(git -C "$GitRepo" symbolic-ref HEAD -q) ]; then
	branch="DETACHED"
else
	branch=$(git -C "$GitRepo" branch --list --points-at HEAD | grep "^* .*")
	branch=${branch:2}  ## Текущая ветка отмечена *. Предполагается результат "* branch", убрать первые 2 символа.
	#branch=$(git -C "$GitRepo" name-rev --name-only HEAD)  ## Возвращает первую попавшую ветку.	
fi
if [ "$branch" ] ; then
  if [ "$dirty" ] ; then
    branch_=$branch-$dirty
  else
    branch_=$branch
  fi
fi


## Header
echo -e "/**\n * This file was created automatically by script build_info.sh.\n * DO NOT EDIT! \n */\n" > $temppath

echo -e "#define BUILD_GIT_SHORT    \"$short\"" >> $temppath
echo -e "#define BUILD_GIT_LONG     \"$long\""  >> $temppath
echo -e "#define BUILD_GIT_COUNT    \"$count\"" >> $temppath

## if result is not "" (working tree is not clean) then dirty.
echo -e "#define BUILD_GIT_DIRTY    \"$dirty\""  >> $temppath
echo -e "#define BUILD_GIT_DIRTY_   \"$_dirty\"" >> $temppath

## Записать тэг.
echo -e "#define BUILD_GIT_TAG      \"$tag_\"" >> $temppath
## Записать ветку. 
echo -e "#define BUILD_GIT_BRANCH   \"$branch_\"" >> $temppath

## Результирующие
if [ "$tag" ] ; then
	build_git="$tag-c$count($short)$_dirty"
	echo -e "#define BUILD_GIT_         BUILD_GIT_TAG \"-c\" BUILD_GIT_COUNT \"(\" BUILD_GIT_SHORT \")\" BUILD_GIT_DIRTY_" >> $temppath
	echo -e "#define BUILD_GIT          \"$build_git\"" >> $temppath
	echo "$build_git, branch:$branch"  ## Сообщить результат в консоль
else
	build_git="$branch-c$count($short)$_dirty"
	echo -e "#define BUILD_GIT_         BUILD_GIT_BRANCH \"-c\" BUILD_GIT_COUNT \"(\" BUILD_GIT_SHORT \")\" BUILD_GIT_DIRTY_" >> $temppath
	echo -e "#define BUILD_GIT          \"$build_git\"" >> $temppath
	echo "$build_git"	## Сообщить результат в консоль
fi
echo -e "//#define BUILD_INFO         \"Build \"__DATE__\" \"__TIME__\" Git \"BUILD_GIT" >> $temppath
echo -e "#define BUILD_INFO         \"Build \" BUILD_DATE_ISO8601 \" Git \" BUILD_GIT" >> $temppath


## Текущее время в числах
echo -e "" >> $temppath
echo -e "#define BUILD_DATE_ISO8601   \"$(date --iso-8601=seconds)\"" >> $temppath
echo -e "#define BUILD_EPOCH1970_SEC  $(date +%s) " >> $temppath
echo -e "#define BUILD_DATE           \"$(date +%F)\"" >> $temppath
echo -e "#define BUILD_TIME           \"$(date +%T)\"" >> $temppath
echo -e "#define BUILD_DATE_TIME      \"$(date +'%F %T')\"" >> $temppath
echo -e "#define BUILD_YEAR           $(date +%Y)" >> $temppath
echo -e "#define BUILD_MONTH          $(date +%m)" >> $temppath
echo -e "#define BUILD_DAY            $(date +%d)" >> $temppath
echo -e "#define BUILD_HOUR           $(date +%H)" >> $temppath
echo -e "#define BUILD_MIN            $(date +%M)" >> $temppath
echo -e "#define BUILD_SEC            $(date +%S)" >> $temppath
echo -e "#define BUILD_NANOSEC        $(date +%N)" >> $temppath


## Копировать файл если есть изменения
if diff "$temppath" "$TargetFile" > /dev/null  ; then
  echo Nothing to change
else
  cp "$temppath" "$TargetFile"
fi

rm "$temppath"
