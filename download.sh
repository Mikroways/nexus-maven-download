#!/bin/bash

set -eo pipefail

if [ -n "DEBUG" ]; then 
  set -x
fi

usage() {
  echo 
  echo Usage: $0
  echo
  echo "  -h nexus-host       Nexus server url. For example: https//nexus.example.com"
  echo "  -r repo             Repository name. For example: maven"
  echo "  -g group_id         Group id]. For example: com.example"
  echo "  -a artifact         Name of artifact. For example: myCustomLibrary"
  echo "  -v version          Version to download. For example: 1.0.0-SNAPSHOT"
  echo "  -u user             Username to authenticate"
  echo "  -p pass             Password to authenticate"
}

exit_abnormal() {
  usage
  exit 1
}

while getopts "h:r:g:a:v:u:p:" options; do
  case "${options}" in  
    h)
      export NEXUS_URL=${OPTARG}
      ;;
    r)
      export MAVEN_REPO=${OPTARG}
      ;;
    g)
      export GROUP_ID=${OPTARG}
      ;;
    a)
      export ARTIFACT_ID=${OPTARG}
      ;;
    v)
      export VERSION=${OPTARG}
      ;;
    u)
      export USERNAME=${OPTARG}
      ;;
    p)
      export PASSWORD=${OPTARG}
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal
      ;;
    *)
      exit_abnormal
      ;;
  esac
done


REQUIRED_ENVS="
NEXUS_URL
MAVEN_REPO
GROUP_ID
ARTIFACT_ID
VERSION
USERNAME
PASSWORD
"

for env in ${REQUIRED_ENVS}; do
  if [ -z "$(printenv $env)" ]; then
    echo "Variable $env not set. Quitting"
    exit_abnormal
  fi
done

AUTH="$USERNAME:$PASSWORD"
FILE_EXTENSION=jar

URL=$(curl --fail -s -X GET -u $AUTH \
    -H  "accept: application/json" \
    "${NEXUS_URL}/service/rest/v1/search/assets?repository=${MAVEN_REPO}&maven.groupId=${GROUP_ID}&maven.artifactId=${ARTIFACT_ID}&maven.baseVersion=${VERSION}&maven.extension=${FILE_EXTENSION}" \
      | jq -rc '.items | .[].downloadUrl' | sort | tail -n 1)

[ -z "$URL" ] && { echo "artifcat not found!" && exit 1; }

curl -s --fail -u $AUTH -o /tmp/artifact.jar $URL
