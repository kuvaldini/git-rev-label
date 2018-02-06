#!/bin/bash

## INFO
## bash is required for operator [[


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
else
	StdErrMod="2>/dev/null"
fi

temppath="$(mktemp -p /dev/shm/)"  ## Файл по идее в ОЗУ http://unix.stackexchange.com/a/188537/156608

short=$(git -C "$GitRepo" rev-parse --short HEAD)
long=$(git -C "$GitRepo" rev-parse HEAD)  #git -C $GitRepo show-ref -h HEAD
count=$(git -C "$GitRepo" rev-list --count HEAD)

git diff-index --quiet HEAD --; isDirty=$?
[[ $isDirty == true ]]  &&   dirty="dirty"  ||   dirty=""
[[ $isDirty == true ]]  &&  _dirty="-dirty" ||  _dirty=""
#if [[ -n $(git -C "$GitRepo" status --porcelain) ]]; then dirty="dirty"; else dirty=""; fi
#if [[ -n $dirty ]] ; then _dirty="-$dirty"; else _dirty=""; fi

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

echo -e "#pragma once\n" >> $temppath

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
echo -e "//#define BUILD_INFO         \"Build \" __DATE__ \" \" __TIME__ \" Git \" BUILD_GIT" >> $temppath
echo -e "#define BUILD_INFO         \"Build \" BUILD_DATE_ISO8601 \" Git \" BUILD_GIT" >> $temppath

## Отдельный файл с текущими датой и времемем
## Separate file with current date and time
## The output should be like:
##	```
##	#define BUILD_DATE_ISO8601   "2018-02-06T18:16:51+02:00"
##	#define BUILD_EPOCH1970_SEC  1517933811 
##	#define BUILD_DATE           "2018-02-06"
##	#define BUILD_TIME           "18:16:51"
##	#define BUILD_DATE_TIME      "2018-02-06 18:16:51"
##	#define BUILD_YEAR           2018
##	#define BUILD_MONTH          02
##	#define BUILD_DAY            06
##	#define BUILD_HOUR           18
##	#define BUILD_MIN            16
##	#define BUILD_SEC            51
##	#define BUILD_NANOSEC        135301337 
##	```
temp_datetime="$(mktemp -p /dev/shm/)"  ## Файл по идее в ОЗУ http://unix.stackexchange.com/a/188537/156608
epoch1970sec=$(date +%s)
echo -e "" > $temp_datetime
echo -e "#define BUILD_DATE_ISO8601   \"$(date --iso-8601=seconds)\"" >> $temp_datetime
echo -e "#define BUILD_EPOCH1970_SEC  $epoch1970sec " >> $temp_datetime
echo -e "#define BUILD_DATE           \"$(date +%F)\"" >> $temp_datetime
echo -e "#define BUILD_TIME           \"$(date +%T)\"" >> $temp_datetime
echo -e "#define BUILD_DATE_TIME      \"$(date +'%F %T')\"" >> $temp_datetime
echo -e "#define BUILD_YEAR           $(date +%Y)" >> $temp_datetime
echo -e "#define BUILD_MONTH          $(date +%m)" >> $temp_datetime
echo -e "#define BUILD_DAY            $(date +%d)" >> $temp_datetime
echo -e "#define BUILD_HOUR           $(date +%H)" >> $temp_datetime
echo -e "#define BUILD_MIN            $(date +%M)" >> $temp_datetime
echo -e "#define BUILD_SEC            $(date +%S)" >> $temp_datetime
echo -e "#define BUILD_NANOSEC        $(date +%N)" >> $temp_datetime

# extract linux epoch timestamp from prev file. `-F` is field-separator, `2>` is stderr redirection.
epoch1970sec_prev=`grep BUILD_EPOCH1970  $TargetFile  2>/dev/null |  awk -F " " '{print $3}'`
if (( $DEBUG_SCRIPT )); then  echo =================  $epoch1970sec; fi

## Использовать предыдующие дату и время, если разница во времени меньше 10 минут
if (( epoch1970sec - epoch1970sec_prev < 600 )); then
	echo -e "" > $temp_datetime
	# extract date-time block from prev file
	awk -v RS="" '/#define BUILD_DATE.*/' $TargetFile  >> $temp_datetime
fi
cat $temp_datetime  >>  $temppath

## ToDo  Всё равно обновлять время если файлы были изменены. Например, учитывать вывод `git status`.


## Копировать файл если есть изменения
if diff "$temppath" "$TargetFile" &>/dev/null  ; then
#if diff "$temppath" "$TargetFile" ; then
  echo Nothing to change
else
  cp "$temppath" "$TargetFile"
  echo Written to "$TargetFile"
fi

rm "$temppath"
