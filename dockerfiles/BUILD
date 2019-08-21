#!/usr/bin/env bash

for packset in build npm_publish store_artifacts remove_stale_artifacts releases_page full git-rev-label ;do
   docker build --build-arg PACKAGE_SET=$packset \
         -t registry.gitlab.com/kyb/git-rev-label/$packset .
   docker push registry.gitlab.com/kyb/git-rev-label/$packset
done

docker tag registry.gitlab.com/kyb/git-rev-label/git-rev-label ikyb/git-rev-label
docker push ikyb/git-rev-label
