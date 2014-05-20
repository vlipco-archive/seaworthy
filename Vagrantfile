# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure VAGRANTFILE_API_VERSION do |config|

  config.vm.synced_folder ".", "/home/vagrant/seaworthy"
  config.vm.box = "vlipco/fedora-20"

  config.vm.provision "shell", privileged: true,
    inline: "/home/vagrant/seaworthy/dev-tools/provisioners/common"
    #path: "dev-tools/provisioners/common"

  config.vm.provision "ansible" do |ansible|
      ansible.groups = { 
        #{}"igniter" => [ "igniter" ],
        "waypoints" => [ "waypoint" ],
        "harbors" => [ "harbor-1" ]
      }
      ansible.playbook = "ansible/cluster.yml"
    end

  config.vm.define "igniter" do |igniter|

    igniter.vm.hostname = "igniter"
    igniter.vm.network "private_network", ip: "10.0.77.10"

    #igniter.vm.provision "shell", privileged: true,
    #  path: "dev-tools/provisioners/igniter"

    #igniter.vm.provision "ansible" do |ansible|
      #ansible.groups = { "igniter" => [ "igniter" ] }
     # ansible.playbook = "ansible/igniter.yml"
    #end

  end


  config.vm.define "waypoint" do |waypoint|

    waypoint.vm.hostname = "waypoint"
    waypoint.vm.network "private_network", ip: "10.0.77.20"

    #waypoint.vm.provision "shell", privileged: true,
    #  path: "dev-tools/provisioners/waypoint"

   #waypoint.vm.provision "ansible" do |ansible|
   #  ansible.groups = { "waypoints" => [ "waypoint" ] }
   #  ansible.playbook = "ansible/waypoint.yml"
   #end

  end

  config.vm.define "harbor-1" do |harbor|

    harbor.vm.hostname = "harbor-1"
    harbor.vm.network "private_network", ip: "10.0.77.30"

    #harbor.vm.provision "shell", privileged: true,
    #  path: "dev-tools/provisioners/harbor-1"
    
    #harbor.vm.provision "ansible" do |ansible|
    #  ansible.groups = { "harbors" => [ "harbor-1" ] }
    #  ansible.playbook = "ansible/harbor.yml"
    #end

  end

  # TODO create ferry machine

  if Vagrant.has_plugin?("vagrant-proxyconf")
    # use with polipo statusbar
    config.yum_proxy.http  = "http://10.0.2.2:3128"
    config.proxy.http  = "http://10.0.2.2:3128"
    config.proxy.no_proxy = "localhost,127.0.0.1,10.0.2.2"
  end

end
