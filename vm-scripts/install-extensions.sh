#!/usr/bin/env bash

extensions=$@

for extension in ${extensions}
do
    # Check if PHP extensions have been installed
    if dpkg --get-selections | grep -cq ${extension}
    then
        echo "${extension} already installed"
    else
        echo "Installing ${extension}"
        apt-get install -y ${extension} > /dev/null 2>&1
    fi
done