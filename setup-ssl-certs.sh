#!/bin/bash

echo "------------------------"
echo "SSL CERTIFICATE SETUP"
echo "------------------------"

echo ""
echo "Enter your domain name (e.g. www.example.com):"
read -p "> " DOMAIN_NAME

echo ""
echo "Enter your email address (optional; for use by Certbot for renewal notices):"
read -p "> " EMAIL_ADDRESS

apt install python3 certbot -y

# certbot unregister if already registered
certbot unregister
if [ -z "$EMAIL_ADDRESS" ]; then
  certbot register  --agree-tos --register-unsafely-without-email
else 
  certbot register --agree-tos --email "$EMAIL_ADDRESS"
fi
certbot certonly --standalone -d "$DOMAIN_NAME" --non-interactive


# Copy SSL certificate files to the Foundry data/Config directory
# This way, the SSL certificate files be available to the the Foundry container, which will bind /home/foundry-user/foundry/data/ to the container's /data folder
cp "/etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem" \
   "/etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem" \
   /home/foundry-user/foundry/data/Config

# Change permissions on the SSL certificates so the Docker container can read them
chmod a+r /home/foundry-user/foundry/data/Config/*.pem