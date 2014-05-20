# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|

  config.vm.synced_folder ".", "/home/vagrant/seaworthy"
  config.vm.box = "vlipco/fedora-20"

  config.vm.provision "shell", privileged: true,
    path: "dev-tools/provisioners/common"

  config.vm.define "waypoint" do |waypoint|
    waypoint.vm.hostname = "waypoint"
    config.vm.network "private_network", ip: "10.0.77.10"
    waypoint.vm.provision "ansible" do |ansible|
      ansible.groups = { "waypoints" => [ "waypoint" ] }
      ansible.playbook = "ansible/waypoint.yml"
    end
  end

  config.vm.define "harbor-1" do |harbor|
    harbor.vm.hostname = "harbor-1"
    config.vm.network "private_network", ip: "10.0.77.20"
    harbor.vm.provision "ansible" do |ansible|
      ansible.groups = { "harbors" => [ "harbor-1" ] }
      ansible.playbook = "ansible/harbor.yml"
    end
    harbor.vm.provision "shell", privileged: true,
      path: "dev-tools/provisioners/harbor-1"
  end

  # TODO create ferry machine

  if Vagrant.has_plugin?("vagrant-proxyconf")
    # use with polipo statusbar
    config.yum_proxy.http  = "http://10.0.2.2:3128"
    config.proxy.http  = "http://10.0.2.2:3128"
    config.proxy.no_proxy = "localhost,127.0.0.1,10.0.2.2"
  end

end
