#!/usr/bin/env bash

# Check if Node has been installed
node -v > /dev/null 2>&1
NODE_IS_INSTALLED=$?

if [[ ${NODE_IS_INSTALLED} -eq 0 ]]
then
    echo "Node already installed"
    exit 0
fi

NODE_VER=$1

# Install node
apt-get update > /dev/null 2>&1
curl -sL https://deb.nodesource.com/setup_${NODE_VER}.x | sudo -E bash -  > /dev/null 2>&1
apt-get install -y nodejs

# Install any global php modules
if [[ -n $2 ]]
then
    NPM_PACKAGES=$2
    npm install ${NPM_PACKAGES[@]} -g
fi
