# [git-revision](git-revision.sh) 
```
wget 'https://gitlab.com/kyb/build-info-header/raw/master/git-revision.sh?inline=false' -qO git-revision.sh  &&  chmod +x git-revision.sh
./git-revision.sh --help
./git-revision.sh --install
```
For more info read comments in the script and look at the help section.
```
Gives information about Git repository revision in format like 'master-c73-gbbb6bec'.
Can fill template string or file. Useful to provide information about version of
the program: branch, tag, commit hash, commits count, dirty status, date and time.
One of the most useful info is count of commits, not taking into account merged branches - only first parent.

USAGE:
   git revision
   git revision [--help|-h|-?]
   git revision [--version|-V]
   git revision '$refname-c\$count-g\$short\$_dirty'
   git revision --format="`cat build_info.template.h`"
   git revision --format-file=build_info.template.h
   git revision --variables [--export]
   eval $( git revision --variables [--export] )

INSTALLATION:
   wget 'https://gitlab.com/kyb/git-revision/raw/master/git-revision.sh?inline=false' -qO git-revision.sh  &&  chmod +x git-revision.sh
   ./git-revision.sh --install|--install-link [--install-dir=/usr/local/bin]
or simply make this script accessable in PATH as git-revision
   ln -s $PWD/git-revision.sh /usr/local/bin/git-revision

UPDATE:
   git revision --update
or
   wget 'https://gitlab.com/kyb/git-revision/raw/master/git-revision.sh?inline=false' -qO /Users/kyb/bin/git-revision  &&  chmod +x /Users/kyb/bin/git-revision

USE CASES:
 * Fill `build_info.template.h` with branch, tag, commit hash, commits count, dirty status.
   Than include result header to acces build information from code.
   See https://gitlab.com/kyb/git-revision/blob/master/build_info.template.h and
   https://gitlab.com/kyb/git-revision/blob/master/create-build-info.sh

More info at https://gitlab.com/kyb/git-revision
AUTHOR kyb (Iva Kyb) https://gitlab.com/kyb
```

-----------------------
-----------------------


# build-info-header (legacy)
##### bash script extracts information from Git and creates C header files with defined symbols to information about current build.

## Use cases
This is super useful when you want store some information about current build in compiled binary.


Shell script creates `build_info.h` C header file with information about repository: branch, tags, timestamps, etc.
Include this header to access build information from code.

```sh
$ ./build_info.sh -h
Usage:  build_info.sh [GitRepo] [TargetFile]
   GitRepo     Any path under Git VCS. If not specified, uses current folder
   TargetFile  Optional, default is ${GitRepoTopLevelPath}/src/build_info.h

```


Output [`build_info.h`](build_info.example.h) looks like:

```C
/**
 * This file was created automatically by script build_info.sh.
 * DO NOT EDIT! 
 */

#pragma once

#define BUILD_GIT_SHORT    "926b3d8"
#define BUILD_GIT_LONG     "926b3d81eeae2b600c2f33de2249a9767e678940"
#define BUILD_GIT_COUNT    "5"
#define BUILD_GIT_DIRTY    "dirty"
#define BUILD_GIT_DIRTY_   "-dirty"
#define BUILD_GIT_TAG      ""
#define BUILD_GIT_BRANCH   "stable-dirty"
#define BUILD_GIT_         BUILD_GIT_BRANCH "-c" BUILD_GIT_COUNT "(" BUILD_GIT_SHORT ")" BUILD_GIT_DIRTY_
#define BUILD_GIT          "stable-c5(926b3d8)-dirty"
//#define BUILD_INFO         "Build " __DATE__ " " __TIME__ " Git " BUILD_GIT
#define BUILD_INFO         "Build " BUILD_DATE_ISO8601 " Git " BUILD_GIT

#define BUILD_DATE_ISO8601   "2018-12-19T16:26:11+02:00"
#define BUILD_DATE_RFC3339   "2018-12-19 16:26:11+02:00"
#define BUILD_EPOCH1970_SEC  1545229571 
#define BUILD_DATE           "2018-12-19"
#define BUILD_TIME           "16:26:11"
#define BUILD_DATE_TIME      "2018-12-19 16:26:11"
#define BUILD_YEAR           2018
#define BUILD_MONTH          12
#define BUILD_DAY            19
#define BUILD_HOUR           16
#define BUILD_MIN            26
#define BUILD_SEC            11
#define BUILD_NANOSEC        348941683
```
#### The quintessence of this output is **`BUILD_GIT`**.

## Requirements
The script should be execeuted in `bash` compatible shell. Because it uses operator `[[` which is not defined in BSD shell.

## Integration
* Complier must know were to find `build_info.h`, so pay attention to include directories.
* It is good approach to ignore genereted file `build_info.h` in VCS.

### Integrate with QMake
With `qmake` generation of build information could be automated as PRE_TARGETDEPS in `.pro` file:
```
## Generate build_info.h
gitinfo.target = info
gitinfo.commands = $$PWD/../tools/build-info-header/build_info.sh  "$$PWD/../"  '$$OUT_PWD/build_info.h'
PRE_TARGETDEPS += info
QMAKE_EXTRA_TARGETS += gitinfo
```
*Note that paths depend on environment and project.*

### Integrate with Atmel Studio
Go to *menu Project -> YourProject Properties (Alt+F7)*, select *Build Events* and fill *Pre-build event command line* with something like following
```
"C:\Program Files\Git\bin\sh"  ..\utils\build-info-header\build_info.sh  .  $(MSBuildProjectDirectory)\src\build_info.h 
```
*Note that paths depend on environment and project.*

#### To be continued...
* Integrate with CMake
* Integrate with Visual Studio
* Integrate with Keil uVision


## Debug
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

## Advanced hacks
### RequireTimeDiffSeconds
When you stay on the same branch, same commit and have same dirty satus the only reason 
to regenerate *build_info.h* is to update timestamps. To save build time meet new feature.
Since commit e15ec7b8200d2f2aebd1db82e0981d1717e78a38 `build_info.h` is rewritten only if difference between 
current and previous timestamps is more than `RequireTimeDiffSeconds`. The default value is 600 - ten minutes.
```
RequireTimeDiffSeconds=10  tools/build-info-header/build_info.sh  .  src/build_info.h
```

### BuildInfo_RevName
`BuildInfo_RevName` is environment variable consumed by this script with is passed to `git rev-list`,
used to tell "count commits from this" or "count commits since date". For more info refer to `git help rev-list`.
Default value is `HEAD`.


## ToDo
* Ability to disable time and date


## Mirrors
* https://gitlab.com/kyb/build-info-header
* https://bitbucket.org/qyw/build_info-generator-git

