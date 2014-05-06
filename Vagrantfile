# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|

  config.vm.box = "vlipco/fedora-20"

  [1111,3333,6666,9999].each do |p|
    config.vm.network "forwarded_port", guest: p, host: p
  end

  provisioner = "dev-tools/bin/bootstrap-vm"
  config.vm.provision "shell", privileged: true, path: provisioner

  # if ENV['JUMBO'] && ENV['JUMBO'] != ""
  config.vm.provider "virtualbox" do |v|
    v.memory = 8000
    v.cpus = 2
  end

end
