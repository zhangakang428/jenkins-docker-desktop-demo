#!/bin/sh
set -eu

mkdir -p /var/jenkins_home/.m2/repository
chown -R jenkins:jenkins /var/jenkins_home

if [ -S /var/run/docker.sock ]; then
  SOCKET_GID="$(stat -c '%g' /var/run/docker.sock)"
  DOCKER_GROUP="$(getent group "${SOCKET_GID}" | cut -d: -f1 || true)"

  if [ -z "${DOCKER_GROUP}" ]; then
    DOCKER_GROUP="docker-host"

    if getent group "${DOCKER_GROUP}" >/dev/null 2>&1; then
      groupmod -g "${SOCKET_GID}" "${DOCKER_GROUP}"
    else
      groupadd -g "${SOCKET_GID}" "${DOCKER_GROUP}"
    fi
  fi

  usermod -aG "${DOCKER_GROUP}" jenkins
else
  echo "WARNING: /var/run/docker.sock is not available; Jenkins Docker pipeline stages will fail." >&2
fi

exec gosu jenkins /usr/local/bin/jenkins.sh "$@"
