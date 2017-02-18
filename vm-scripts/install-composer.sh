#!/usr/bin/env bash

# Check if Composer has been installed
composer -v > /dev/null 2>&1
COMPOSER_IS_INSTALLED=$?

if [ $COMPOSER_IS_INSTALLED -eq 0 ]
then
    echo "Composer already installed"
    exit 0
fi

# Install Composer https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
sudo mv composer.phar /usr/local/bin/composer
rm composer-setup.php

# Add composer home vendor bin dir to PATH to run globally installed executables
if [[ -f "/home/vagrant/.profile" ]]
then
    if ! grep -cqs 'COMPOSER_HOME=' /home/vagrant/.profile
    then
        printf "\n# Add composer global bin to PATH\nCOMPOSER_HOME=\"$(composer config -g home)\"" >> /home/vagrant/.profile
        printf "\nexport PATH=\$PATH:\$COMPOSER_HOME/vendor/bin" >> /home/vagrant/.profile

        . /home/vagrant/.profile
    fi
fi

# Install any global Composer packages
if [ ! $# -eq 0 ]
then
    COMPOSER_PACKAGES=$1
    echo "Installing global composer packages ${COMPOSER_PACKAGES[@]}"
    composer global require "${COMPOSER_PACKAGES[@]}" > /dev/null 2>&1
fi
