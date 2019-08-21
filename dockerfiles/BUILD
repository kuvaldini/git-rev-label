#!/usr/bin/env bash

foreach(){
   for packset in build npm_publish store_artifacts remove_stale_artifacts releases_page full git-rev-label ;do
      "$@" $packset
   done
}

build_one(){
   docker build --build-arg PACKAGE_SET=$1 \
         -t registry.gitlab.com/kyb/git-rev-label/$1 .
}

build_all(){
   foreach build_one
}

push_one(){
   docker push registry.gitlab.com/kyb/git-rev-label/$1
}

push_all(){
   foreach push_one
}

build_and_push_one(){
   build_one $1  &&  push_one $1
}

build_and_push_all(){
   foreach build_and_push_one
   tag_and_push_hub_docker_com
}

tag_and_push_hub_docker_com(){
   docker tag registry.gitlab.com/kyb/git-rev-label/git-rev-label ikyb/git-rev-label
   docker push ikyb/git-rev-label
}

cmd=${1:-build_and_push_all}
shift
$cmd "$@"

#for packset in build npm_publish store_artifacts remove_stale_artifacts releases_page full git-rev-label ;do
#   docker build --build-arg PACKAGE_SET=$packset \
#         -t registry.gitlab.com/kyb/git-rev-label/$packset .
#   docker push registry.gitlab.com/kyb/git-rev-label/$packset
#done
