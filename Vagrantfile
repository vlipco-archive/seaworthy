# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# todo add fpm,fish,bc in provisioning

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "vlipco/fedora-20"

  #vagrant ssh -- -L 8500:127.0.0.1:8500

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "10.77.77.5"

  config.vm.provision "shell", inline: "gem install fpm && yum install -y fish bc"

end
