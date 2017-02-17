#!/usr/bin/env bash

# Check if Apache has been installed
apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

if [ $APACHE_IS_INSTALLED -eq 0 ]
then
    echo "Apache already installed"
    exit 0
fi

APACHE_MODULES=$1

# Install Apache
apt update > /dev/null 2>&1
apt-get install -y apache2 > /dev/null 2>&1

# PHP uses the prefork module
# Disable default multi-processing module (MPM) event module and enable prefork module
a2dismod mpm_event > /dev/null 2>&1
a2enmod mpm_prefork > /dev/null 2>&1

# Enable any additional apache modules
a2enmod ${APACHE_MODULES[@]} > /dev/null 2>&1

# Run apache as vagrant user
if grep -cqs 'APACHE_RUN_USER=www-data' /etc/apache2/envvars
then
    sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
fi

# Add vagrant user to www-data group
adduser vagrant www-data > /dev/null 2>&1

systemctl restart apache2 > /dev/null 2>&1