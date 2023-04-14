#!/bin/bash

echo "Enter your Foundry Timed Release URL:"
read -p '> ' FOUNDRY_RELEASE_URL

VERSION=10.291.0

docker buildx build \
  --platform linux/amd64 \
  --build-arg FOUNDRY_RELEASE_URL=$FOUNDRY_RELEASE_URL \
  --build-arg VERSION=$VERSION \
  --output type=docker \
  --tag my-foundryvtt:$VERSION \
  https://github.com/felddy/foundryvtt-docker.git#develop

docker save my-foundryvtt:$VERSION | gzip > my-image.tar.gz
