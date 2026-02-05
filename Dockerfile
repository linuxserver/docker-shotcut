# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

# set version label
ARG BUILD_DATE
ARG VERSION
ARG SHOTCUT_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV \
  HOME="/config" \
  TITLE="Shotcut" \
  NO_GAMEPAD="true"

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/shotcut-logo.png && \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libjack-jackd2-0 \
    libsdl2-2.0-0 \
    xz-utils && \
  echo "**** install shotcut ****" && \
  mkdir -p \
    /app/shotcut && \
  if [ -z ${SHOTCUT_RELEASE+x} ]; then \
    SHOTCUT_RELEASE=$(curl -sX GET "https://api.github.com/repos/mltframework/shotcut/releases/latest" \
    | jq -r .tag_name); \
  fi && \
  SHOTCUT_URL=$(curl -sX GET "https://api.github.com/repos/mltframework/shotcut/releases/tags/${SHOTCUT_RELEASE}" | jq -r '.assets[].browser_download_url' \
    | grep "x86_64" | grep ".txz") && \
  curl -fo \
    /tmp/shotcut-tarball.txz -L \
    "${SHOTCUT_URL}" && \
  tar xvf /tmp/shotcut-tarball.txz -C \
    /app/shotcut --strip-components=1 && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /
