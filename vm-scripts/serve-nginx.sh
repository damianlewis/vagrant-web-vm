#!/usr/bin/env bash

www_host=$1
www_root=$2
php_ver=$3

if [[ -f "/etc/nginx/sites-available/${www_host}" ]]
then
    echo "${www_host} site already available"
    exit 0
fi

mkdir -p /var/log/nginx/${www_host}

block="server {
    listen 80 default_server;
    server_name ${www_host} www.${www_host};
    root ${www_root};

    charset utf-8;
    index index.html index.htm index.php;

    access_log off;
    error_log  /var/log/nginx/${www_host}/error.log error;

    sendfile off;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        fastcgi_pass unix:/run/php/php${php_ver}-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}"

echo "${block}" > "/etc/nginx/sites-available/${www_host}"

ln -fs "/etc/nginx/sites-available/${www_host}" "/etc/nginx/sites-enabled/${www_host}"
rm /etc/nginx/sites-enabled/default
systemctl restart nginx