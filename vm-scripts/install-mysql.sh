#!/usr/bin/env bash

# Check if MySQL has been installed
mysql --version > /dev/null 2>&1
MYSQL_IS_INSTALLED=$?

if [ ${MYSQL_IS_INSTALLED} -eq 0 ]
then
    echo "MySQL already installed"
    exit 0
fi

PHP_VER=$1

apt-get update > /dev/null 2>&1

# Install MySQL without password prompt
# Set username and password to 'root'
debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"

apt-get install -y mysql-server php${PHP_VER}-mysql > /dev/null 2>&1