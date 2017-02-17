#!/usr/bin/env bash

block="<VirtualHost *:80>
       ServerName $1
       ServerAlias www.$1
       DocumentRoot $2

        <Directory $2>
            AllowOverride All
            Require all granted
        </Directory>

       ErrorLog ${APACHE_LOG_DIR}/error.log
       CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>"

echo "$block" > "/etc/apache2/sites-available/$1.conf"

a2ensite $1.conf > /dev/null 2>&1
a2dissite 000-default > /dev/null 2>&1
systemctl restart apache2 > /dev/null 2>&1
