#!/usr/bin/env bash

# Check if Apache has been installed
apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

if [[ ${APACHE_IS_INSTALLED} -eq 0 ]]
then
    echo "Apache already installed"
    exit 0
fi

apt-get update > /dev/null 2>&1
apt-get install -y apache2 > /dev/null 2>&1

# Enable Fast CGI for use with PHP-FPM
a2enmod proxy proxy_fcgi > /dev/null 2>&1

# Run apache as vagrant user
sed -i 's/www-data/vagrant/' /etc/apache2/envvars

# Add vagrant user to www-data group
adduser vagrant www-data > /dev/null 2>&1

systemctl restart apache2 > /dev/null 2>&1