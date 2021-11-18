# -*- mode: ruby -*-

require 'open3'

MACHINES = {
  "server" => {
    "name" => "LAB_RAID_server"
  }
}

def virtualbox_vm_info(vm_name)
  stdout, stderr, status  = Open3.capture3("VBoxManage showvminfo --machinereadable '#{vm_name}'")
  raise stderr if status.exitstatus.nonzero?
  return stdout
end

def virtualbox_add_controller(config, name, type)
  config.vm.provider "virtualbox" do |v|
    v.customize [ "storagectl", :id,
                  "--name", name,
                  "--add", type ]

    puts "in provider in virtualbox_add_controller"
  end
end

def add_disks(config, vm_name)
  begin
    vm_info = virtualbox_vm_info(vm_name)
  rescue => e
  end

  sata_controller_name = "SATA"
  nvme_controller_name = "NVME"
  has_sata = false
  has_nvme = false

  if vm_info

    params = {}
    for line in vm_info.split(/\n/)
      key, value = line.split("=", 2).map { |x| x.sub(/"(.*)"/) { $1 } }
      params[key] = value
    end

    if params.any? { |k, v| k =~ /storagecontrollertype(\d+)/ && v.downcase == "intelahci" }
      has_sata = true
      sata_controller_name = params["storagecontrollername" + $1]
    end

    if params.any? { |k, v| k =~ /storagecontrollername(\d+)/ && v == nvme_controller_name }
      has_nvme = true
    end
    
    unless has_nvme
      virtualbox_add_controller(config, name = nvme_controller_name, type = "pcie")
    end

    unless has_sata
      virtualbox_add_controller(config, name = sata_controller_name, type = "sata")
    end
    
    config.vm.provider "virtualbox" do |v|
      puts "in_provider_virtualbox"
    end
  end
  
end



Vagrant.configure("2") do |config|

  config.vm.boot_timeout = 600 # very slow pc
  
  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|
      box.vm.box = "bento/centos-8"
      #box.vm.box = "centos/8"

      box.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
        v.name = boxconfig["name"]

        #virtualbox_add_controller( boxconfig["name"], box, type="sata", name="SATA")
      end

      add_disks( box, boxconfig["name"] )

    end
    
  end
  
end

