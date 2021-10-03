# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.


NODE_IP_NW   = "192.168.28."

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.box_check_update = false
  config.ssh.insert_key = false
  config.ssh.private_key_path = "insecure_private_key"



  (10..22).each do |i|
    hostname= "vm#{i}"
    config.vm.define(hostname) do |node|
      node.vm.hostname = hostname
      node.vm.network :private_network, nic_type: "virtio", ip: NODE_IP_NW + "#{i}"
      node.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--cpus", "1"]
        vb.customize ["modifyvm", :id, "--memory", "1024"]
      end
      node.vm.provision "shell", inline: <<-SHELL
        pushd /vagrant/ > /dev/null || exit
          bash ./000-sys.sh
          bash ./001-net-#{i}.sh
        popd > /dev/null || exit
      SHELL
    end
  end

end