#!/bin/bash

echo "Enter your Foundry Timed Release URL:"
read -p 'URL: ' FOUNDRY_RELEASE_URL

docker build \
  --build-arg FOUNDRY_RELEASE_URL=$FOUNDRY_RELEASE_URL \
  --build-arg VERSION=10.291.0 \
  --tag my/foundryvtt:10.291.0 \
  https://github.com/felddy/foundryvtt-docker.git#develop