#!/usr/bin/env bash

# Check if PHP has been installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [ $PHP_IS_INSTALLED -eq 0 ]
then
    echo "PHP already installed"
    exit 0
fi

PHP_TYPE=$1
PHP_MODULES=$2
PHP_VER=$3

apt-get update > /dev/null 2>&1
apt-get install -y ${PHP_MODULES[@]}

# Log errors to /var/log/php/error.log
if grep -cqs ';error_log = php_errors.log' /etc/php/${PHP_VER}/${PHP_TYPE}/php.ini
then
    mkdir /var/log/php
    chown www-data /var/log/php
    sed -i 's/;error_log = php_errors.log/error_log = \/var\/log\/php\/error.log/' /etc/php/${PHP_VER}/${PHP_TYPE}/php.ini
fi