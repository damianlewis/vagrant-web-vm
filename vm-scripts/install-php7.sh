#!/usr/bin/env bash

# Check if PHP has been installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [ $PHP_IS_INSTALLED -eq 0 ]
then
    echo "PHP already installed"
    exit 0
fi

PHP_MODULES=$1

# Install php 7
apt update > /dev/null 2>&1
apt-get install -y php7.0 php-pear libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-zip > /dev/null 2>&1

# Install any additional php modules
if [ ! $# -eq 0 ]
then
    PHP_MODULES=$1
    echo "Installing additional PHP modules ${PHP_MODULES[@]}"
    apt-get install -y ${PHP_MODULES[@]} > /dev/null 2>&1
fi

# Log errors to /var/log/php/error.log
if grep -cqs ';error_log = php_errors.log' /etc/php/7.0/apache2/php.ini
then
    mkdir /var/log/php
    chown www-data /var/log/php
    sed -i 's/;error_log = php_errors.log/error_log = \/var\/log\/php\/error.log/' /etc/php/7.0/apache2/php.ini
fi

systemctl restart apache2 > /dev/null 2>&1