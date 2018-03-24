# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-stretch64"
  config.vm.network "private_network", ip: "192.168.33.102"
  config.ssh.insert_key = true
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb|
     vb.name = "hashistack-pki"
     vb.customize ["modifyvm", :id, "--memory", "4096"]
     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "provisioning/standalone.yml"
  end

end
