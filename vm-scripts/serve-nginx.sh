#!/usr/bin/env bash

HOST=$1
ROOT=$2
PHP_VER=$3

block="server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root $ROOT;

    index index.html index.htm index.php;

    server_name $HOST www.$HOST;

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    access_log off;
    error_log  /var/log/nginx/$HOST/error.log error;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php$PHP_VER-fpm.sock;
    }
}"

echo "$block" > "/etc/nginx/sites-available/$HOST"

ln -fs "/etc/nginx/sites-available/$HOST" "/etc/nginx/sites-enabled/$HOST"
rm /etc/nginx/sites-enabled/default
systemctl restart nginx > /dev/null 2>&1