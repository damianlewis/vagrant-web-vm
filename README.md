# LEMP/LAMP development VM

## Description
Provides a Linux web development environment using an Ubuntu 16.04 Vagrant box. Uses Nginx, PHP 7.0 and MySQL 5.7 but can be configured to use Apache and PHP 7.1.

### Configuration
The VM can be configured using the `vm.yaml` configuration file.
###### VM
The IP address for the VM can be changed by updating the `ip` setting. Also the default name for the VM is 'damianlewis', this can be changed by adding the `name` setting. The default hostname for the VM is also 'damianlewis', this can be changed by adding the `hostname` setting.
```
ip: "192.168.22.18"
name: vmname
hostname: vmhostname
```
To use NFS for your synced folder, add the `nfs` setting.
```
ip: "192.168.10.10"
nfs: true
```
###### Apache
To use Apache add the following `type` setting:
```
ip: "192.168.10.10"
type: apache
```
###### PHP
To use PHP 7.1 add the following `php-ver` setting:
```
ip: "192.168.10.10"
php-ver: "7.1"
```
###### MySQL
The default user created for databases is 'damianlewis' with the password 'secret'.
###### Post provisioning
Use the `post.sh` file to run any further provisions that you require for your VM.
###### Bash aliases
A number of default bash aliases are created for the VM. These can be found in the `aliases` file. Add any further aliases you require to this file before creating the VM.
##### Other software included
- Composer (with Laravel Envoy)
- NVM and Node (with Gulp and Webpack)
