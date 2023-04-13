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

# Destroy terraform infrastructure
terraform destroy -var "do_token=${DO_PAT}" -var "pvt_key=${PVT_KEY}"  -var "pub_key=${PUB_KEY}"