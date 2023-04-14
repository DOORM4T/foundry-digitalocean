#!/bin/bash

# Ensure terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "Terraform could not be found. Please install terraform and try again."
    exit
fi

# Ensure ansible is installed
if ! command -v ansible &> /dev/null
then
    echo "Ansible could not be found. Please install ansible and try again."
    exit
fi

# Get user input for credentials
echo ""
echo "Enter Digital Ocean token (input will be hidden):"
read -p "> " -s DO_PAT

echo ""
echo "Enter private key location:"
read -p "> " PVT_KEY

echo ""
echo "Enter public key location:"
read -p "> " PUB_KEY

echo ""
echo "Enter root domain name (e.g. example.com)"
read -p "> " DOMAIN_NAME

echo ""
echo "Enter subdomain name (e.g. www)"
read -p "> " SUBDOMAIN_NAME

echo ""
echo "Enter foundrydata.zip location on your local machine (e.g. ~/Documents/foundry/backups/foundrydata.zip)"
echo "Can be left blank if you don't have a backup to restore from."
read -p "> " FOUNDRYDATA_ZIP

Run terraform
echo "Running terraform..."
terraform init
terraform apply -var "do_token=${DO_PAT}" -var "pvt_key=${PVT_KEY}" -var "pub_key=${PUB_KEY}" -var "domain_name=${DOMAIN_NAME}" -var "subdomain_name=${SUBDOMAIN_NAME}" -var "existing_foundry_zip_data_path=${FOUNDRYDATA_ZIP}"