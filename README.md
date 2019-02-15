# [git-rev-label](git-rev-label.sh) 
```
wget 'https://gitlab.com/kyb/build-info-header/raw/master/git-rev-label.sh?inline=false' -qO git-rev-label.sh  &&  chmod +x git-rev-label.sh
./git-rev-label.sh --help
./git-rev-label.sh --install
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
   git revision '$refname-c$count-g$short$_dirty'
   git revision --format='$refname-g$short$_dirty'
   git revision --format-file=build_info.template.h
   git revision --variables [--export]
   eval $( git revision --variables [--export] )

INSTALLATION:
   wget 'https://gitlab.com/kyb/git-rev-label/raw/master/git-rev-label.sh?inline=false' -qO git-rev-label.sh  &&  chmod +x git-rev-label.sh
   ./git-rev-label.sh --install|--install-link [--install-dir=/usr/local/bin]
or simply make this script accessable in PATH as git-rev-label
   ln -s $PWD/git-rev-label.sh /usr/local/bin/git-rev-label

UPDATE:
   git revision --update
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
brew install ivakyb/homebrew-git-rev-label/git-rev-label
```


-----------------------
-----------------------

This was the begining.

# [build-info-header](legacy-build_info) (legacy)
##### bash script extracts information from Git and creates C header files with defined symbols to information about current build.

## Use cases
This is super useful when you want store some information about current build in compiled binary.


Shell script creates `build_info.h` C header file with information about repository: branch, tags, timestamps, etc.
Include this header to access build information from code.
