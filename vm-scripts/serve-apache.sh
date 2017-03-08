#!/usr/bin/env bash

HOST=$1
ROOT=$2

block="<VirtualHost *:80>
    ServerName $HOST
    ServerAlias www.$HOST
    DocumentRoot $ROOT

    <Directory $ROOT>
        AllowOverride All
        Require all granted
    </Directory>

    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>"

echo "$block" > "/etc/apache2/sites-available/$HOST.conf"

a2ensite $HOST.conf > /dev/null 2>&1
a2dissite 000-default > /dev/null 2>&1
systemctl restart apache2 > /dev/null 2>&1