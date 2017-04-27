#!/usr/bin/env bash

php_ver=$1
php_path="/etc/php/${php_ver}"
xdebug_path="${php_path}/mods-available/xdebug.ini"

if [[ -f ${xdebug_path} ]]
then
    echo "Xdebug already available"
else
    git clone git://github.com/xdebug/xdebug.git > /dev/null 2>&1

    # Check if phpize has been installed
    phpize -v > /dev/null 2>&1
    is_installed=$?

    if [[ ${is_installed} != 0 ]]
    then
        apt-get install -y php${php_ver}-dev > /dev/null 2>&1
    fi

    # Build xdebug extension
    cd xdebug
    phpize > /dev/null 2>&1
    ./configure > /dev/null 2>&1
    make > /dev/null 2>&1
    make install > /dev/null 2>&1

    cd ..
    rm -rf xdebug
fi

# Enable extension
block="zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_port=9000"

echo "${block}" > ${xdebug_path}
ln -sf ${xdebug_path} ${php_path}/fpm/conf.d/20-xdebug.ini
ln -sf ${xdebug_path} ${php_path}/cli/conf.d/20-xdebug.ini

systemctl restart php${php_ver}-fpm