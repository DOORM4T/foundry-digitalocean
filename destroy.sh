#!/bin/bash

# Ensure terraform is installed
if ! command -v terraform &> /dev/null
then
    echo "Terraform could not be found. Please install terraform and try again."
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

# Destroy terraform infrastructure
terraform destroy -var "do_token=${DO_PAT}" -var "pvt_key=${PVT_KEY}"  -var "pub_key=${PUB_KEY}" -var "foundry_timed_url=''" -var "domain_name=${DOMAIN_NAME}" -var "subdomain_name=${SUBDOMAIN_NAME}"