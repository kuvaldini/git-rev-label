Shell script creates `build_info.h` C header file with information about repository: branch, tags, timestamps, etc.
Include this header to access build information from code.

```
#!shell

$ ./build_info.sh -h
Usage:  build_info.sh [GitRepo] [TargetFile]
   GitRepo     Any path under Git VCS. If not specified, uses current folder
   TargetFile  Optional, default is ${GitRepoTopLevelPath}/src/build_info.h

```


Output `build_info.h` looks like:

```C
/**
 * This file was created automatically by script build_info.sh.
 * DO NOT EDIT! 
 */

#define BUILD_GIT_SHORT    "2973efa"
#define BUILD_GIT_LONG     "2973efa5554c7a14730e48f18ba671eb23df9958"
#define BUILD_GIT_DIRTY    "dirty"
#define BUILD_GIT_DIRTY_   "-dirty"
#define BUILD_GIT_TAG      ""
#define BUILD_GIT_BRANCH   "config-file-dirty"
#define BUILD_GIT_         BUILD_GIT_BRANCH"("BUILD_GIT_SHORT")"BUILD_GIT_DIRTY_
#define BUILD_GIT          "config-file(2973efa)-dirty"
//#define BUILD_INFO         "Build "__DATE__" "__TIME__" Git "BUILD_GIT
#define BUILD_INFO         "Build "BUILD_DATE_ISO8601" Git "BUILD_GIT

#define BUILD_DATE_ISO8601   "2017-05-28T13:40:25+0300"
#define BUILD_EPOCH1970_SEC  1495968025 
#define BUILD_DATE           "2017-05-28"
#define BUILD_TIME           "13:40:25"
#define BUILD_DATE_TIME      "2017-05-28 13:40:25"
#define BUILD_YEAR           2017
#define BUILD_MONTH          05
#define BUILD_DAY            28
#define BUILD_HOUR           13
#define BUILD_MIN            40
#define BUILD_SEC            25
#define BUILD_NANOSEC        623915100

```


## Mirrors
* https://gitlab.com/kyb/build-info-header
* https://bitbucket.org/qyw/build_info-generator-git

