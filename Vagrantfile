# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

settings = YAML::load(File.read("vm.yaml"))
after_script_path = "after.sh"
aliases_path = "aliases"
script_dir = File.expand_path("vm-scripts", File.dirname(__FILE__))
type = settings["type"] ||= "lemp"
php_ver = settings["php-ver"] ||= "7.0"

Vagrant.configure("2") do |config|
    # Create bash aliases
    if File.exists? aliases_path then
        config.vm.provision "file", source: aliases_path, destination: "~/.bash_aliases"
    end

    # Prevent TTY errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Allow SSH Agent Forward from The Box
    config.ssh.forward_agent = true

    # Configure the vagrant box
    config.vm.define settings["name"] ||= "damianlewis"
    config.vm.box = settings["box"] ||= "damianlewis/#{type}-php#{php_ver}"
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.10.10"
    config.vm.hostname = settings["hostname"] ||= "damianlewis"

    # Configure VirtualBox settings
    config.vm.provider "virtualbox" do |vb|
        vb.name = settings["name"] ||= "damianlewis"
        vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
        vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
        vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
    end

    # Default port forwarding
    default_ports = {
        80   => 8000,
        443  => 44300,
        3306 => 33060
    }

    # Use default port forwarding unless overridden
    default_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
    end

    # Register all the configured shared folders
    if settings.include? 'folders'
        settings["folders"].each do |folder|
            mount_opts = []

            if (folder["type"] == "nfs")
                mount_opts = folder["mount_options"] ? folder["mount_options"] : ['actimeo=1', 'nolock']
            end

            # For b/w compatibility keep separate 'mount_opts', but merge with options
            options = (folder["options"] || {}).merge({ mount_options: mount_opts })

            # Double-splat (**) operator only works with symbol keys, so convert
            options.keys.each{|k| options[k.to_sym] = options.delete(k) }

            config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, **options
        end
    end

    # Create all configured sites
    if settings.include? 'sites'
        if (type == "lamp")
            server = "apache"
        else
            server = "nginx"
        end

        settings["sites"].each do |site|
            config.vm.provision "shell" do |s|
                s.name = "Creating Site: " + site["map"]
                s.path = script_dir + "/serve-#{server}.sh"
                s.args = [site["map"], site["to"], php_ver]
            end
        end
    end

    # Create all the configured databases
    if settings.has_key?("databases")
        settings["databases"].each do |db|
            config.vm.provision "shell" do |s|
                s.name = "Creating MySQL Database: " + db
                s.path = script_dir + "/create-mysql.sh"
                s.args = [db, "damianlewis", "secret"]
            end
        end
    end

    # Run post provisioning script
    if File.exists? after_script_path then
        config.vm.provision "shell", path: after_script_path
    end
end