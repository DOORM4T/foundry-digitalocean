#!/bin/bash

CONTAINER_NAME="foundryvtt"

### Prompt for droplet ip/domain name and ssh key so the script can execute commands on the droplet
echo "Enter droplet ip/domain name:"
read -p "> " DROPLET_HOSTNAME

echo "Enter ssh private key location for $DROPLET_HOSTNAME:"
read -p "> " SSH_KEY

### Check if foundryvtt container is running/stopped on droplet
### Stop the container if it is running
if ssh -i $SSH_KEY foundry-user@$DROPLET_HOSTNAME "sudo docker ps | grep $CONTAINER_NAME"; then
  echo "Foundry VTT container is running on $DROPLET_HOSTNAME. Stopping container..."
  ssh -i $SSH_KEY foundry-user@$DROPLET_HOSTNAME "sudo docker stop $CONTAINER_NAME"
else
  echo "Foundry VTT container is not running on $DROPLET_HOSTNAME."
fi

### Back up foundry data from /home/foundry-user/foundry/data

### On the droplet...
### First, create a backup directory if it doesn't exist
REMOTE_BACKUP_DIRECTORY_PATH=/home/foundry-user/foundry/backups
ssh -i $SSH_KEY foundry-user@$DROPLET_HOSTNAME "sudo mkdir -p /home/foundry-user/foundry/backups"

### Zip the latest foundry data to a 'backups' directory
echo "Backing up foundry data..."
TIMESTAMP=`date +"%Y-%m-%d_%H-%M-%S"`                                            # Timestamp for the zip file name
ZIP_FILE_OUTPUT_PATH="$REMOTE_BACKUP_DIRECTORY_PATH/foundrydata_$TIMESTAMP.zip"  # Output path for the backup zip file
DATA_PATH=/home/foundry-user/foundry/data                                        # Path of the foundry data directory on the droplet. 
                                                                                 # We want to back up all folders/files in its root, such as 'Data', 'Config', etc.

echo "Zipping foundry data from $DATA_PATH to $ZIP_FILE_OUTPUT_PATH..."
ssh -i $SSH_KEY foundry-user@$DROPLET_HOSTNAME "cd $DATA_PATH && sudo zip -r $ZIP_FILE_OUTPUT_PATH *" 

### Copy the backup zip file to the local machine
echo "Copying backup at $DROPLET_HOSTNAME:$ZIP_FILE_OUTPUT_PATH to backups/ on local machine..."
LOCAL_BACKUP_DIRECTORY_PATH="backups"
mkdir -p $LOCAL_BACKUP_DIRECTORY_PATH
scp -i $SSH_KEY foundry-user@$DROPLET_HOSTNAME:$ZIP_FILE_OUTPUT_PATH $LOCAL_BACKUP_DIRECTORY_PATH