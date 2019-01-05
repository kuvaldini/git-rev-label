/**
 * This file was created automatically by script build_info.sh.
 * DO NOT EDIT! 
 */

#pragma once

#define BUILD_GIT_SHORT    "$short"
#define BUILD_GIT_LONG     "$long"
#define BUILD_GIT_COUNT    "$count"
#define BUILD_GIT_DIRTY    "$dirty"
#define BUILD_GIT_DIRTY_   "$_dirty"
#define BUILD_GIT_TAG      "$tag_"
#define BUILD_GIT_BRANCH   "$branch_"
#define BUILD_GIT_         BUILD_GIT_BRANCH "-c" BUILD_GIT_COUNT "(" BUILD_GIT_SHORT ")" BUILD_GIT_DIRTY_
#define BUILD_GIT          "$refname-c$count-g$short$_DIRTY"
#define BUILD_INFO         "Build " __DATE__ " " __TIME__ " Git " BUILD_GIT
