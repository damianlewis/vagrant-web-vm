# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

settings = YAML::load(File.read("vm.yaml"))
post_script = "post.sh"
aliases = "aliases"
script_dir = File.expand_path("vm-scripts", File.dirname(__FILE__))
type = settings["type"] ||= "lemp"
php_ver = settings["php-ver"] ||= "7.0"

unless type == "lamp" || type == "lemp"
    abort("Development stack {type: #{type}} not recognised. Only lamp or lemp are supported.")
end

unless php_ver == "7.0" || php_ver == "7.1"
    abort("PHP {php-ver: #{php_ver}} not supported. Only versions 7.0 and 7.1 are supported.")
end

# Synced folder
folder = {
    "map" => ".",
    "to" => "/vagrant"
}

# Default ports for forwarding
default_ports = {
    80 => 8000,
    3306 => 33060
}

Vagrant.configure("2") do |config|
    # Create bash aliases
    if File.exists? aliases
        config.vm.provision "file", source: aliases, destination: "~/.bash_aliases"
    end

    # Prevent TTY errors (https://coderwall.com/p/qtbi5a/prevent-stdin-is-not-a-tty-error-in-vagrant)
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Enable SSH agent forwarding
    config.ssh.forward_agent = true

    # Configure the vagrant box
    config.vm.define settings["name"] ||= "damianlewis"
    config.vm.box = settings["box"] ||= "damianlewis/#{type}-php#{php_ver}"
    config.vm.box_version = settings["version"] ||= ">= 1.1.0"
    config.vm.network "private_network", ip: settings["ip"] ||= "192.168.10.10"
    config.vm.hostname = settings["hostname"] ||= "damianlewis"

    # Configure VirtualBox settings
    config.vm.provider "virtualbox" do |vb|
        vb.name = settings["name"] ||= "damianlewis"
        vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
        vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
        vb.customize ["modifyvm", :id, "--ostype", settings["os"] ||= "Ubuntu_64"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", settings["natdnshostresolver"] ||= "off"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", settings["natdnsproxy"] ||= "off"]
    end

    # Configure default ports
    default_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
    end

    # Configure shared folder
    if settings.has_key?("nfs") && settings["nfs"] == true
        config.vm.synced_folder folder["map"], folder["to"], type: "nfs", mount_options: ['actimeo=1', 'nolock']
    else
        config.vm.synced_folder folder["map"], folder["to"]
    end

    # Install additional PHP extensions/modules
    if settings.has_key?("extensions") && settings["extensions"].kind_of?(Array)
        extensions = settings["extensions"]
        config.vm.provision "shell" do |s|
            s.name = "Installing additional PHP extensions"
            s.path = script_dir + "/install-extensions.sh"
            s.args = extensions
        end

        config.vm.provision "shell" do |s|
            s.name = "Restarting PHP"
            s.inline = "systemctl restart php$1-fpm"
            s.args = [php_ver]
       end
    end

    # Install Xdebug
    if settings.has_key?("xdebug") && settings["xdebug"] == true
        config.vm.provision "shell" do |s|
            s.name = "Installing Xdebug"
            s.path = script_dir + "/install-xdebug.sh"
            s.args = [php_ver]
        end
    end

    # Install Laravel Envoy
    if settings.has_key?("envoy") && settings["envoy"] == true
        config.vm.provision "shell" do |s|
            s.name = "Installing Laravel Envoy"
            s.path = script_dir + "/install-envoy.sh"
            s.privileged = false
        end
    end

    # Create site
    if settings.has_key?("site")
        config.vm.provision "shell" do |s|
            s.name = "Creating Site: " + settings["site"]
            s.path = script_dir + "/serve-#{type == "lamp" ? "apache" : "nginx"}.sh"
            s.args = [settings["site"], settings["root"] ||= folder["to"], php_ver]
        end
    end

    # Create all the configured databases
    if settings.has_key?("databases") && settings["databases"].kind_of?(Array)
        settings["databases"].each do |db|
            config.vm.provision "shell" do |s|
                s.name = "Creating MySQL Database: " + db
                s.path = script_dir + "/create-mysql.sh"
                s.args = [db, "damianlewis", "secret"]
            end
        end
    end

    # Run post provisioning script
    if File.exists? post_script
        config.vm.provision "shell", path: post_script
    end
end
