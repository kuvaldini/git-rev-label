[![pipeline status](https://gitlab.com/kyb/git-rev-label/badges/master/pipeline.svg)](https://gitlab.com/kyb/git-rev-label/pipelines?scope=branches)


# [git-rev-label](git-rev-label.sh) 
Gives information about Git repository revision in format like 'master-c73-gabc6bec'. 
Can fill template string or file with environment variables and information from Git. 
Useful to provide information about version of the program: branch, tag, commit hash, 
commits count, dirty status, date and time. One of the most useful things is count of 
commits, not taking into account merged branches - only first parent.

### Part 2 – Walk over git commits and show how rev-label detects branch, tag, detached and dirty states
[ ![](demo/demo-part2-walk-over-commits.gif) ](https://asciinema.org/a/li8MyPUwOfaS5T9GmxjbZXQeV)  

### Part 3 – List available variables and fill template file
[ ![](demo/demo-part3-variables-and-template.svg) ](https://asciinema.org/a/MZJ7joO22DwPFS7Uwyru5Zs8e)


## Usage
```
$ git rev-label
master-c73-gbbb6bec
```

```
$ git rev-label --help
Gives information about Git repository revision in format like 'master-c73-gbbb6bec'.
Can fill template string or file with environment variables and information from Git. 
Useful to provide information about version of the program: branch, tag, commit hash, 
commits count, dirty status, date and time. One of the most useful things is count of 
commits, not taking into account merged branches - only first parent.

USAGE:
   git rev-label
   git rev-label [--help|-h|-?]
   git rev-label [--version|-V]
   git rev-label '$refname-c\$count-g\$short\$_dirty'
   git rev-label --format="`cat build_info.template.h`"
   git rev-label --format-file=build_info.template.h
   git rev-label --variables [--export]
   eval $( git rev-label --variables [--export] )

COMPLEX USE CASE:
 * Fill `build_info.template.h` with branch, tag, commit hash, commits count, dirty status. 
   Than include result header to access build information from code. 
   See https://gitlab.com/kyb/git-rev-label/blob/master/build_info.template.h and
   https://gitlab.com/kyb/git-rev-label/blob/master/create-build-info.sh

INSTALLATION:
   ./git-rev-label --install|--install-link [--install-dir=/usr/local/bin]

UPDATE:
   git rev-label --update

More info at https://gitlab.com/kyb/git-rev-label
```

## Run witout install
*  
  ```
  npx git-rev-label
  ```
* 
  ``` 
  docker run -it ikyb/git-rev-label
  ```
  If wanna run always in container
  ```
  alias git-rev-label='docker run -it --rm -v"$PWD":"$PWD" -w"$PWD" ikyb/git-rev-label git-rev-label '
  ```
  or create executable file git-rev-label in PATH with the same contents.

## Install
#### Manual
```
wget 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' && sudo bash ./git-rev-label --install
```
*Warning: sudo under hood.*  

Without sudo, install to `$HOME/bin`:
```
wget 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' && 
  bash ./git-rev-label --install --install-dir=$HOME/bin
```

Make sure `$HOME/bin` is in `$PATH`:
* bash  
  ```
  [[ ":$PATH:" != *":$HOME/bin:"* ]] && PATH="$HOME/bin:$PATH"
  ```
* fish  
  ```
  set --export --universal fish_user_paths ~/bin $fish_user_paths
  ```

#### with [NPM](https://npm.org)
    npm install --global git-rev-label

#### with [Homebrew](https://brew.sh)
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
