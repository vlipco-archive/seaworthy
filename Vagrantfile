# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|

  config.vm.synced_folder ".", "/home/vagrant/seaworthy"
  config.vm.box = "vlipco/fedora-20"

  config.vm.define "igniter" do |igniter|
    igniter.vm.hostname = "igniter"
    igniter.vm.network "private_network", ip: "10.0.77.10"
  end

  config.vm.define "waypoint" do |waypoint|
    waypoint.vm.hostname = "waypoint"
    waypoint.vm.network "private_network", ip: "10.0.77.20"
  end

  config.vm.define "harbor-1" do |harbor|
    harbor.vm.hostname = "harbor-1"
    harbor.vm.network "private_network", ip: "10.0.77.30"
  end

  config.vm.define "ferry" do |ferry|
    ferry.vm.hostname = "ferry"
    ferry.vm.network "private_network", ip: "10.0.77.50"

    # Provisioning only on last machine since ansible deals with multiple hosts
    config.vm.provision "ansible" do |ansible|
      ansible.groups = {}
      ansible.groups["waypoints"] = ["waypoint"]
      ansible.groups["harbors"] = ["harbor-1"]
      ansible.groups["ferries"] = ["ferry"]
      ansible.playbook = "ansible/seaworthy.yml"
      ansible.limit = 'all'
      ansible.extra_vars = { vagrant_development: true }
    end

  end

  # TODO create ferry machine

  # use cache proxy if available, e.g. polipo statusbar
  #if Vagrant.has_plugin? "vagrant-proxyconf"
  #  config.yum_proxy.http  = "http://10.0.2.2:3128"
  #  #config.proxy.http  = "http://10.0.2.2:3128"
  #  no_proxy = %w(10.0.2.2 10.0.77.30 10.0.77.20 10.0.77.10)
  #  no_proxy.push *%w(localhost 127.0.0.1)
  #  config.proxy.no_proxy = no_proxy.join ','
  #end

end
