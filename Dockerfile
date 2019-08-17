FROM alpine:latest

LABEL maintainer="https://gitlab.com/kyb"
LABEL description="Image to build, test, deploy and play with git-rev-label"

ARG PACKAGE_SET=git-rev-label
ENV PACKAGE_SET=$PACKAGE_SET
RUN echo PACKAGE_SET="$PACKAGE_SET" >&2
RUN case $PACKAGE_SET in \
        build)                  PACKAGES="bash git perl" ;; \
        npm_publish)            PACKAGES="npm bash" ;; \
        store_artifacts)        PACKAGES="bash git perl openssh-client" ;; \
        remove_stale_artifacts) PACKAGES="git openssh-client" ;; \
        releases_page)          PACKAGES="curl jq bash git" ;; \
        full)                   PACKAGES="bash git perl curl jq openssh-client npm" ;; \
        git-rev-label)          PACKAGES="bash git perl wget" ;; \
    esac; \
    apk add --no-cache --update $PACKAGES
RUN case "$PACKAGE_SET" in build|git-rev-label|full) \
        wget 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' && bash ./git-rev-label --install ;\
    esac

ENTRYPOINT bash
