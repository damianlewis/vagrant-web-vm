#!/usr/bin/env bash

HOST=$1
ROOT=$2
PHP_VER=$3

mkdir -p /var/log/apache2/${HOST}

block="<VirtualHost *:80>
    ServerName $HOST
    ServerAlias www.$HOST
    DocumentRoot $ROOT

    <Directory $ROOT>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler \"proxy:unix:/run/php/php$PHP_VER-fpm.sock|fcgi://localhost/\"
    </FilesMatch>

    ErrorLog \${APACHE_LOG_DIR}/$HOST/error.log
    # Possible values include: debug, info, notice, warn, error, crit, alert, emerg
    LogLevel warn
    CustomLog \${APACHE_LOG_DIR}/$HOST/access.log combined
</VirtualHost>"

echo "$block" > "/etc/apache2/sites-available/$HOST.conf"

a2ensite ${HOST}.conf > /dev/null 2>&1
a2dissite 000-default > /dev/null 2>&1
systemctl restart apache2 > /dev/null 2>&1