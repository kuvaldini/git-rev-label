FROM alpine:latest

LABEL maintainer="https://gitlab.com/kyb"
LABEL description="Image to build, test, deploy and play with git-rev-label"

ARG PACKAGE_SET=git-rev-label
ENV PACKAGE_SET=$PACKAGE_SET
RUN echo PACKAGE_SET="$PACKAGE_SET" >&2
RUN case $PACKAGE_SET in \
        build)                  PACKAGES="bash git perl" ;; \
        store_artifacts)        PACKAGES="bash git perl openssh-client" ;; \
        remove_stale_artifacts) PACKAGES="     git      openssh-client" ;; \
        npm_publish)            PACKAGES="bash                         npm" ;; \
        releases_page)          PACKAGES="bash git                         curl jq" ;; \
        full)                   PACKAGES="bash git perl openssh-client npm curl jq" ;; \
        git-rev-label)          PACKAGES="bash git perl                    wget" ;; \
    esac; \
    apk add --no-cache --update $PACKAGES
RUN case "$PACKAGE_SET" in build|git-rev-label|full) \
        wget 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' && bash ./git-rev-label --install ;\
    esac
