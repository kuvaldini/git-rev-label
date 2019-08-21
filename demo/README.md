```
#!/usr/bin/env fish

git rev-label --version
git-rev-label --help

git rev-label
git rev-label '$refname-c\$count-g\$short\$_dirty'

## Fill template header file to pass rev-label to C/C++
git rev-label --format-from=build_info.template.h | lolcat -F 0.03
cat build_info.h
colordiff build_info.template.h build_info.h 

## List variables filled by script, use them in --format
git rev-label --variables

## Fill a template with variables from environment
env A="asdf cxz" git rev-label 'hello-$A-$refname'

## Walk over git commits and show how rev-label detects branch, tag, detached, dirty
echo >a
git status
## DIRTY
git rev-label
git checkout master^
git rev-label
## 133-1=132
git checkout --detach
git rev-label
## DETACHED and DIRTY
git commit a -m"add a"
git status
## no dirty status
git tag asdf
git rev-label
## $tag is used because no branch has been found

git rev-label --update

```