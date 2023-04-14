#!/bin/bash

echo "Enter your Foundry Timed Release URL:"
read -p '> ' FOUNDRY_RELEASE_URL

VERSION=10.291.0

docker build \
  --build-arg FOUNDRY_RELEASE_URL=$FOUNDRY_RELEASE_URL \
  --build-arg VERSION=$VERSION \
  --tag my-foundryvtt:$VERSION \
  https://github.com/felddy/foundryvtt-docker.git#develop

docker save my-foundryvtt:$VERSION | gzip > my-foundryvtt_$VERSION.tar.gz
