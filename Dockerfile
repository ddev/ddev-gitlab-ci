FROM docker:latest

LABEL org.opencontainers.image.source https://github.com/ochorocho/ddev-docker

ARG ddev_version
ENV DDEV_VERSION=${ddev_version}

COPY ddev-install.sh ddev-install.sh
RUN ash ddev-install.sh
USER ddev
RUN mkcert -install