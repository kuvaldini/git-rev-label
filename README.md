[![pipeline status](https://gitlab.com/kyb/git-rev-label/badges/master/pipeline.svg)](https://gitlab.com/kyb/git-rev-label/pipelines?scope=branches)


# [git-rev-label](git-rev-label.sh) 

## Download and Install
```
wget 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' && sudo bash ./git-rev-label --install
```
*Warning: sudo under hood.*

## Usage
For more info read comments in the script and look at the help section.
```
Gives information about Git repository revision in format like 'master-c73-gbbb6bec'.
Can fill template string or file with environment variables and information from Git. 
Useful to provide information about version of the program: branch, tag, commit hash, 
commits count, dirty status, date and time. One of the most useful things is count of 
commits, not taking into account merged branches - only first parent.

USAGE:
   git rev-label
   git rev-label [--help|-h|-?]
   git rev-label [--version|-V]
   git rev-label '$refname-c$count-g$short$_dirty'
   git rev-label --format='$refname-g$short$_dirty'
   git rev-label --format-file=build_info.template.h
   git rev-label --variables [--export]
   eval $( git rev-label --variables [--export] )

INSTALLATION:
   wget 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' && chmod +x git-rev-label 
   ./git-rev-label --install|--install-link [--install-dir=/usr/local/bin]
or simply make this script accessable in PATH as git-rev-label
   ln -s $PWD/git-rev-label.sh /usr/local/bin/git-rev-label

UPDATE:
   git rev-label --update
or
   wget 'https://gitlab.com/kyb/git-rev-label/raw/master/git-rev-label.sh?inline=false' -qO ~/bin/git-rev-label  &&  chmod +x ~/bin/git-rev-label

USE CASES:
 * Fill `build_info.template.h` with branch, tag, commit hash, commits count, dirty status.
   Than include result header to acces build information from code.
   See https://gitlab.com/kyb/git-rev-label/blob/master/build_info.template.h and
   https://gitlab.com/kyb/git-rev-label/blob/master/create-build-info.sh

More info at https://gitlab.com/kyb/git-rev-label
AUTHOR kyb (Iva Kyb) https://gitlab.com/kyb
```

## Install with [Homebrew](https://brew.sh)
```
brew tap ivakyb/git-rev-label
brew install git-rev-label
```


-----------------------
-----------------------


# [build-info-header](legacy-build_info) (legacy)
This was the begining.
##### bash script extracts information from Git and creates C header files with defined symbols to information about current build.

## Use cases
This is super useful when you want store some information about current build in compiled binary.


Shell script creates `build_info.h` C header file with information about repository: branch, tags, timestamps, etc.
Include this header to access build information from code.
