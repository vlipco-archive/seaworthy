# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|

  config.vm.box = "vlipco/fedora-20"

  [1111,3333,6666,9999].each do |p|
    config.vm.network "forwarded_port", guest: p, host: p
  end

  provisioner = "dev-tools/bin/bootstrap-vm"
  config.vm.provision "shell", privileged: true, path: provisioner

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"


  # if ENV['JUMBO'] && ENV['JUMBO'] != ""
  config.vm.provider "virtualbox" do |v|
    v.memory = 8000
    v.cpus = 2
  end

end
