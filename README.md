# LEMP/LAMP development VM

## Description
Provides a Linux web development environment using an Ubuntu 16.04 Vagrant box. Uses Nginx, PHP 7.0 and MySQL 5.7 but can be configured to use Apache and PHP 7.1.

### Configuration
The VM can be configured using the `vm.yaml` configuration file.
###### VM
The IP address for the VM can be changed by updating the `ip` property. Also the default name for the VM is 'damianlewis', this can be changed by adding the `name` property. The default hostname for the VM is also 'damianlewis', this can be changed by adding the `hostname` property.
```
ip: "192.168.22.18"
name: vmname
hostname: vmhostname
```
To use NFS for your synced folder, add the `nfs` property.
```
ip: "192.168.10.10"
nfs: true
```
###### Apache
To use Apache add the following `type` property:
```
ip: "192.168.10.10"
type: lamp
```
###### PHP
To use PHP 7.1 add the following `php-ver` property:
```
ip: "192.168.10.10"
php-ver: "7.1"
```
###### Xdebug
To install Xdebug add the following `xdebug` property:
```
ip: "192.168.10.10"
xdebug: true
```
###### Site
You can set up a site by mapping a domain name to a root folder on the VM. The domain name is set via the `site` property and the root folder set via the `root` property.
```
ip: "192.168.10.10"
site: site.dev
root: /vagrant
```
The domain name must be added to your machines `hosts` file. Example: 
```
192.168.10.10   site.dev
```
###### Databases
You can create a MySQL database by adding the name for the database to the `databases` property.
```
databases:
    - dbname
```
Multiple databases can be created as follows:
```
databases:
    - dbname
    - dbname
    - dbname
```
The default user created for the databases is `damianlewis` with the password `secret`.
###### Post provisioning
Use the `post.sh` file to run any further provisions that you require for your VM.
###### Bash aliases
A number of default bash aliases are created for the VM. These can be found in the `aliases` file. Add any further aliases you require to this file before creating the VM.
#### Software included
- Ubuntu 16.04.3 LTS
- Nginx 1.10.3 _or_ Apache 2.4.18
- PHP 7.0.22 _or_ 7.1.9 with the following modules and extensions:
    - curl
    - mysql
    - gd
    - mbstring
    - xml
    - zip
- MySQL 5.7.19
- Composer 1.5.1
- NVM with Node 8.4.0 and the following global packages:
    - Bower 1.8.0
    - Grunt 1.2.0
    - Gulp 1.4.0
    - Yarn 0.27.5
