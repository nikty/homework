# -*- mode: ruby -*-

require 'open3'
require 'fileutils'


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


def virtualbox_create_disk_file(config, filename, size)
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


def add_disks(config_obj, vm_name, disk_config)
  return unless disk_config

  vbox_vm_id = get_vm_id(vm_name)
  
  begin
    vm_info = virtualbox_vm_info(vbox_vm_id)
  rescue => e
  end

  #### Disk configuration
  sata_controller_name = "SATA#1"
  nvme_controller_name = "NVME#1"
  has_sata = false
  has_nvme = false
  disk_dir = "#{vm_name}_disks"

  #### 

  if !File.directory?(disk_dir)
    FileUtils.mkdir_p(disk_dir)
  end


  if vm_info
    params = {}
    for line in vm_info.split(/\n/)
      key, value = line.split("=", 2).map { |x| x.sub(/"(.*)"/) { $1 } }
      params[key] = value
    end

    params.each do |k, v|
      if k =~ /storagecontrollertype(\d+)/ && v.downcase == "intelahci"
        has_sata = true
        sata_controller_name = params["storagecontrollername" + $1]
      end

      if k =~ /storagecontrollername(\d+)/ && v == nvme_controller_name
        has_nvme = true
      end
    end
  end
    
    

  
  disk_config.reduce({}) { |h, el| (h[ el[:type] ] ||= []) << el; h }.each do |type, disks|
    if type == "nvme" && !has_nvme
      virtualbox_add_storage_controller(config_obj, name = nvme_controller_name, type = "pcie")
    end


    if type =="sata" && !has_sata
      virtualbox_add_storage_controller(config_obj, name = sata_controller_name, type = "sata")
    end
    
    disks.each_with_index do |el, i|
      
      # Assume boot disk is on SATA port 0
      # Also start from NVME port 0, VM can't see disks otherwise
      port = (type == "sata") ? i + 1 : i 

      filename = "#{disk_dir}/#{ type }_#{ i.to_s }.vdi"
      virtualbox_create_disk_file(config_obj, filename, el[:size]) unless File.exist?(filename)
      virtualbox_attach_disk(config_obj,
                             (type == "sata") ?
                               sata_controller_name :
                               (type == "nvme") ? nvme_controller_name : nil,
                             port,
                             filename)
    end
  end
end


