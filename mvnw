#!/bin/sh
set -eu

if command -v mvn >/dev/null 2>&1; then
  exec mvn "$@"
fi

MAVEN_VERSION="${MAVEN_VERSION:-3.9.9}"
MAVEN_USER_HOME="${MAVEN_USER_HOME:-${HOME}/.m2}"
MAVEN_BASE="${MAVEN_USER_HOME}/wrapper/dists/apache-maven-${MAVEN_VERSION}"
MAVEN_HOME="${MAVEN_BASE}/apache-maven-${MAVEN_VERSION}"
MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"

if [ ! -x "${MAVEN_HOME}/bin/mvn" ]; then
  mkdir -p "${MAVEN_BASE}"
  curl -fsSL "${MAVEN_URL}" | tar -xz -C "${MAVEN_BASE}"
fi

exec "${MAVEN_HOME}/bin/mvn" "$@"
