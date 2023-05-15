#!/bin/bash

echo "------------------------"
echo "FOUNDRY VTT DOCKER SETUP"
echo "------------------------"

VERSION="10.291.0"
IMAGE_TAG="my-foundryvtt:$VERSION"

# If foundryvtt container already exists, allow the user to delete it and continue setup
# Otherwise, don't delete it and exit setup
if [ "$(docker ps -q -f name=foundryvtt)" ]; then
  echo "Existing Foundry VTT container found."

  echo "Delete existing container? (y/n)"
  read -p '> ' FOUNDRY_DELETE

  if [ "$FOUNDRY_DELETE" == "y" ]; then
    echo "Deleting existing container..."
    docker stop foundryvtt > /dev/null
    docker rm foundryvtt > /dev/null
    echo "Successfully deleted existing container."
  else
    echo "Did not delete existing container. Exiting launch script."
    exit;
  fi
fi

# Continue setup...
echo ""
echo "Bind path to data volume (e.g. /home/foundry-user/foundry/data):"
read -p '> ' FOUNDRY_DATA
if [ -z "$FOUNDRY_DATA" ]; then
  echo "Data volume path required"
  exit 1
fi

# Option to configure SSL
echo "Configure SSL? (y/n)"
read -p '> ' FOUNDRY_SSL

if [ "$FOUNDRY_SSL" == "y" ]; then
  echo "Configuring SSL:"
  echo "Path to SSL CERT (e.g. /data/Config/fullchain.pem):"
  echo "This should be relative to the /data volume of the Foundry container"
  read -p '> ' FOUNDRY_SSL_CERT

  if [ -z "$FOUNDRY_SSL_CERT" ]; then
    echo "SSL CERT required"
    exit 1
  fi

  echo "Path to SSL KEY (e.g. /data/Config/privkey.pem):"
  echo "This should be relative to the /data volume of the Foundry container"
  read -p '> ' FOUNDRY_SSL_KEY

  if [ -z "$FOUNDRY_SSL_KEY" ]; then
    echo "SSL KEY required"
    exit 1
  fi

  docker run \
    -e CONTAINER_CACHE='foundryvtt-10.291.zip' \
    -e FOUNDRY_SSL_CERT=$FOUNDRY_SSL_CERT \
    -e FOUNDRY_SSL_KEY=$FOUNDRY_SSL_KEY \
    -v $FOUNDRY_DATA:/data \
    -p 443:30000 \
    --name foundryvtt \
    --restart unless-stopped \
    -d \
    $IMAGE_TAG \
    > /dev/null

  echo "Foundry VTT is now starting at https://localhost:443"
else
  echo "SSL disabled"
  docker run \
    -e CONTAINER_CACHE='foundryvtt-10.291.zip' \
    -v $FOUNDRY_DATA:/data \
    -p 80:30000 \
    --name foundryvtt \
    --restart unless-stopped \
    -d \
    $IMAGE_TAG \
    > /dev/null


  echo "Foundry VTT is now starting at http://localhost:80"
fi

# Follow logs
sleep 5
echo "Following container logs..."
docker logs -f foundryvtt


