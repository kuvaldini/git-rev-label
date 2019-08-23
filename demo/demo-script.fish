#!/usr/bin/env fish

## PART 1
## Common features
git rev-label --version
git-rev-label --help

## Basic features
git rev-label
git rev-label '$refname-c\$count-g\$short\$_dirty'
git rev-label --format='$branch-C\$COUNT-g\$LONG\$_DIRTY'


## PART 2
## Walk over git commits and show how rev-label detects branch, tag, detached and dirty states
git status
## clean
echo a >a
git status
git rev-label
## dirty
git checkout HEAD^
git rev-label
## count -1, DETACHED and DIRTY
git add a && git commit -m"add a"
git status
git tag -f brantozyabra
git rev-label
## count +1, no dirty status
## $tag is used because of detached state


## PART 3
## List available variables and fill template file
git rev-label --variables
## Use them in --format=string

## Also can take variables from environment
env A="lovely World" B="git-rev-label" git rev-label 'Hello, my $A, from $B $refname. Here is $unset variable.'

## Fill template header file to pass rev-label to C/C++
cd build_info-header
git rev-label --format-from=build_info.template.h | tee build_info.h | lolcat -F 0.02
colordiff build_info{.template,}.h --side-by-side
## Variable placeholders were filled


## PART 4
## Self-Maintenance
#todo curl -fsSL https://git-rev-label.sh | bash
git rev-label --update
