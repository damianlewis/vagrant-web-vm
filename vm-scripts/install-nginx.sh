#!/usr/bin/env bash

# Check if Nginx has been installed
nginx -v > /dev/null 2>&1
NGINX_IS_INSTALLED=$?

if [[ ${NGINX_IS_INSTALLED} -eq 0 ]]
then
    echo "Nginx already installed"
    exit 0
fi

apt-get update > /dev/null 2>&1
apt-get install -y nginx > /dev/null 2>&1

# Run Nginx as vagrant user
if grep -cqs 'user www-data;' /etc/nginx/nginx.conf
then
    sed -i 's/user www-data;/user vagrant;/' /etc/nginx/nginx.conf
fi

# Add vagrant user to www-data group
adduser vagrant www-data > /dev/null 2>&1

systemctl restart nginx > /dev/null 2>&1