#!/usr/bin/env bash

# Check if PHP has been installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [[ ${PHP_IS_INSTALLED} -eq 0 ]]
then
    echo "PHP already installed"
    exit 0
fi

PHP_MODULES=$1
PHP_VER=$2
PHP_INI="/etc/php/${PHP_VER}/fpm/php.ini"

apt-get update > /dev/null 2>&1
apt-get install -y ${PHP_MODULES[@]} > /dev/null 2>&1

# Run php-fpm as vagrant user
sed -i 's/www-data/vagrant/' /etc/php/${PHP_VER}/fpm/pool.d/www.conf

# Log errors to /var/log/php/error.log
if grep -cqs ';error_log = php_errors.log' ${PHP_INI}
then
    mkdir /var/log/php
    chown www-data /var/log/php
    sed -i 's/;error_log = php_errors.log/error_log = \/var\/log\/php\/error.log/' ${PHP_INI}
fi

systemctl restart php${PHP_VER}-fpm > /dev/null 2>&1