# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|

  config.vm.synced_folder ".", "/home/vagrant/seaworthy"
  config.vm.box = "vlipco/fedora-20"

  config.vm.define "igniter" do |igniter|
    igniter.vm.hostname = "igniter"
    igniter.vm.network "private_network", ip: "10.0.77.10"
    igniter.vm.network "forwarded_port", guest: 8500, host: 8500
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
    ferry.vm.provision "ansible" do |ansible|
      ansible.groups = {}
      ansible.groups["waypoints"] = ["waypoint"]
      ansible.groups["harbors"] = ["harbor-1"]
      ansible.groups["ferries"] = ["ferry"]
      ansible.playbook = "ansible/site.yml"
      #ansible.tags = "geard"
      ansible.extra_vars = { 
        vagrant_development: true, 
        clean_vendor_install: false 
      }
      ansible.limit = 'all'
    end
  end

end
