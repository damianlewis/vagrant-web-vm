#!/usr/bin/env bash

cat > /root/.my.cnf << EOF
[client]
user = root
password = secret
host = localhost
EOF

cp /root/.my.cnf /home/vagrant/.my.cnf

DB=$1;
USER=$2;
PASSWORD=$3;

mysql -e "CREATE DATABASE IF NOT EXISTS \`$DB\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";
mysql -e "GRANT ALL ON \`$DB\`.* TO '$USER'@'localhost' IDENTIFIED BY '$PASSWORD';"
mysql -e "FLUSH PRIVILEGES;"
systemctl restart mysql > /dev/null 2>&1