# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

VAGRANTFILE_API_VERSION ||= "2"
settings = YAML::load(File.read("vm.yaml"))
afterScriptPath = "after.sh"
aliasesPath = "aliases"
scriptDir = File.expand_path("vm-scripts", File.dirname(__FILE__))

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # Create bash aliases
    if File.exists? aliasesPath then
        config.vm.provision "file", source: aliasesPath, destination: "~/.bash_aliases"
    end

    # Prevent TTY errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Allow SSH Agent Forward from The Box
    config.ssh.forward_agent = true

    # Configure the vagrant box
    config.vm.define settings["name"] ||= "damianlewis"
    config.vm.box = settings["box"] ||= "bento/ubuntu-16.04"
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
        3306 => 33060,
        5432 => 54320
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

    # Install Apache
    config.vm.provision "shell" do |s|
        s.name = "Installing Apache"
        s.path = scriptDir + "/install-apache.sh"
        if settings.include? 'apache-modules'
            s.args = [settings["apache-modules"].join(" ")]
        end
    end

    # Install PHP 7
    config.vm.provision "shell" do |s|
        s.name = "Installing PHP 7"
        s.path = scriptDir + "/install-php7.sh"
        if settings.include? 'php-modules'
            s.args = [settings["php-modules"].join(" ")]
        end
    end

    # Install MySQL
    config.vm.provision "shell" do |s|
        s.name = "Installing MySQL"
        s.path = scriptDir + "/install-mysql.sh"
    end

    # Install Composer
    config.vm.provision "shell" do |s|
        s.name = "Installing Composer"
        s.path = scriptDir + "/install-composer.sh"
        if settings.include? 'composer-packages'
            s.args = [settings["composer-packages"].join(" ")]
        end
        s.privileged = false
    end

    # Install Node
    config.vm.provision "shell" do |s|
        s.name = "Installing Node"
        s.path = scriptDir + "/install-node.sh"
        if settings.include? 'npm-packages'
            s.args = [settings["npm-packages"].join(" ")]
        end
    end

    # Install all configured sites
    if settings.include? 'sites'
        settings["sites"].each do |site|
            type = site["type"] ||= "apache"

            config.vm.provision "shell" do |s|
                s.name = "Creating Site: " + site["map"]
                s.path = scriptDir + "/serve-#{type}.sh"
                s.args = [site["map"], site["to"]]
            end
        end
    end

    # Create all the configured databases
    if settings.has_key?("databases")
        settings["databases"].each do |db|
            config.vm.provision "shell" do |s|
                s.name = "Creating MySQL Database: " + db["name"]
                s.path = scriptDir + "/create-mysql.sh"
                s.args = [db["name"], db["user"] ||= "damianlewis", db["password"] ||= "secret"]
            end
        end
    end

    # Run post provisioning script
    if File.exists? afterScriptPath then
        config.vm.provision "shell", path: afterScriptPath
    end
end