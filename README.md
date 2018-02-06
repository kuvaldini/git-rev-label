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
#define BUILD_GIT_         BUILD_GIT_BRANCH "(" BUILD_GIT_SHORT ")" BUILD_GIT_DIRTY_
#define BUILD_GIT          "config-file(2973efa)-dirty"
//#define BUILD_INFO         "Build "__DATE__" "__TIME__" Git "BUILD_GIT
#define BUILD_INFO         "Build " BUILD_DATE_ISO8601 " Git " BUILD_GIT

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


### Integration
* Complier must know were to find `build_info.h`, so pay attention to include directories.
* It is good approach to ignore genereted file `build_info.h` in VCS.

With `qmake` generation of build information could be automated as PRE_TARGET in `.pro` file:
```
# generate build_info.h
gitinfo.target = info
gitinfo.commands = $$PWD/../tools/build-info-header/build_info.sh  "$$PWD/../"  '$$OUT_PWD/build_info.h'
PRE_TARGETDEPS += info
QMAKE_EXTRA_TARGETS += gitinfo
```
Note that paths depend on environment and project.

#### To be continued...
* Integrate with CMake
* Integrate with Atmel Studio
* Integrate with Visual Studio
* Integrate with Keil uVision


### Debug
The script could be more verbose with non zero `DEBUG_SCRIPT` variable:
```
DEBUG_SCRIPT=1  tools/build-info-header/build_info.sh . Common/build_info.h
```
Output:
```
GitRepo: .
GitRepoTopLevelPath:
TargetFile: Common/build_info.h
video2-c222(112c53c)
BUILD_EPOCH1970_SEC 1517953535
Nothing to change
```


## Mirrors
* https://gitlab.com/kyb/build-info-header
* https://bitbucket.org/qyw/build_info-generator-git

