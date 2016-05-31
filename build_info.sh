#!/bin/sh

## Создаёт или редактирует файл build_info.h
## 
##

filepath="$(git rev-parse --show-toplevel)/src/build_info.h"
#filepath=${filepath////\\}  ## Replace all / to \

## Header
echo -e "/**\n * This file was created automatically by script.\n * DO NOT EDIT! \n */\n" > $filepath

short=$(git rev-parse --short HEAD)
echo -e "#define BUILD_GIT_SHORT  \"$short\"" >> $filepath
long=$(git rev-parse HEAD)
echo -e "#define BUILD_GIT_LONG   \"$long\"" >> $filepath

[[ $(git status --porcelain) ]] && dirty="dirty" || dirty=""
echo -e "#define BUILD_GIT_DIRTY  \"${dirty}\"" >> $filepath

echo -e "#define BUILD_GIT        BUILD_GIT_SHORT\"-\"BUILD_GIT_DIRTY" >> $filepath
echo -e "#define BUILD_GIT_       \"$short-$dirty\"" >> $filepath
