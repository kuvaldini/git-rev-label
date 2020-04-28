FROM alpine:latest

LABEL maintainer="https://gitlab.com/kyb"
LABEL description="Image to build, test, deploy and play with git-rev-label"

RUN apk add --no-cache --update bash git perl wget
ADD git-rev-label
RUN bash ./git-rev-label --install
#RUN wget 'https://gitlab.com/kyb/git-rev-label/raw/artifacts/master/git-rev-label' \
#    && bash ./git-rev-label --install
