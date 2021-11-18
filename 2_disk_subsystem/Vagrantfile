# -*- mode: ruby -*-

require 'open3'
require 'fileutils'

MACHINES = {
  "server" => {

  }
}

def virtualbox_vm_info(vm_name)
  return if vm_name.empty?
  stdout, stderr, status  = Open3.capture3("VBoxManage showvminfo --machinereadable '#{vm_name}'")
  raise stderr if status.exitstatus.nonzero?
  return stdout
end

def get_vm_id(name="default")
  file = ".vagrant/machines/" + name.to_s + "/virtualbox/id"
  if File.exist?(file)
    File.read(file)
  end
end
  
def virtualbox_add_storage_controller(config, name, type)
  config.vm.provider "virtualbox" do |v|
    v.customize [ "storagectl", :id,
                  "--name", name,
                  "--add", type ]

  end
end


def virtualbox_create_disk(config, filename, size)
  puts filename
  config.vm.provider "virtualbox" do |v|
    v.customize [ "createmedium", "disk", "--filename", filename, "--size", size ]
  end
end


def virtualbox_attach_disk(config, ctl_name, ctl_port, filename)
  config.vm.provider "virtualbox" do |v|
    v.customize [ "storageattach", :id, "--storagectl", ctl_name,
                  "--port", ctl_port,
                  "--type", "hdd",
                  "--medium", filename ]
  end
end


def add_disks(config_obj, name)

  vbox_vm_id = get_vm_id(name)
  
  begin
    vm_info = virtualbox_vm_info(vbox_vm_id)
  rescue => e
  end

  sata_controller_name = "SATA#1"
  nvme_controller_name = "NVME#1"
  has_sata = false
  has_nvme = false
  disk_dir = "vm_disks"

  disks = []
  6.times do
    disks << { type: "sata", size: 1024 }
  end

  5.times do
    disks << { type: "nvme", size: 1024 }
  end

  if !File.directory?(disk_dir)
    FileUtils.mkdir_p(disk_dir)
  end


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
    
    
  end

  unless has_nvme
    virtualbox_add_storage_controller(config_obj, name = nvme_controller_name, type = "pcie")
  end


  unless has_sata
    virtualbox_add_storage_controller(config_obj, name = sata_controller_name, type = "sata")
  end

  disks.reduce({}) { |h, el| (h[ el[:type] ] ||= []) << el; h }.each do |type, disks|
    disks.each_with_index do |el, i|
      port = i + 1 # Assume boot disk is on port 0
      filename = "#{disk_dir}/#{ type }_#{ i.to_s }.vdi"
      virtualbox_create_disk(config_obj, filename, el[:size]) unless File.exist?(filename)
      virtualbox_attach_disk(config_obj,
                             (type == "sata") ?
                               sata_controller_name :
                               (type == "nvme") ? nvme_controller_name : nil,
                             port,
                             filename)
    end
  end
  
  
  
end



Vagrant.configure("2") do |config|

  config.vm.boot_timeout = 10*60
  
  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|
      #box.vm.box = "bento/centos-8"
      box.vm.box = "centos/8"
      config.vm.box_version = "2011.0"
      
      #virtualbox_vm_id = get_vm_id( boxname )
      
      box.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
        #v.name = boxconfig["name"]

      end

      add_disks( box, boxname )

    end
    
  end
  
end

