#!/usr/bin/env bash

HOST=$1
ROOT=$2

block="server {
    listen 80;
    listen [::]:80;

    server_name $HOST www.$HOST;

    root $ROOT;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }
}"

echo "$block" > "/etc/nginx/sites-available/$HOST"

ln -fs "/etc/nginx/sites-available/$HOST" "/etc/nginx/sites-enabled/$HOST"
rm /etc/nginx/sites-enabled/default
systemctl restart nginx > /dev/null 2>&1