packer {
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "vm_description" {
  type    = string
  default = "CentOS 7 with kernel 5.x"
}

variable "vm_version" {
  type    = string
  default = "7"
}

variable "image_name" {
  type    = string
  default = "centos-7"
}


source "virtualbox-iso" "centos-7" {

  vm_name           = "packer-centos-vm"

  cpus = 1
  disk_size = "10240"
  memory = 1024

  guest_os_type = "RedHat_64"
  iso_checksum = "sha256:07b94e6b1a0b0260b94c83d6bb76b26bf7a310dc78d7a9c7432809fb9bc6194a"
  #iso_checksum_type = "sha256"
  #iso_url = "file:/home/lab/shared/CentOS-7-x86_64-Minimal-2009.iso"
  iso_url = "http://mirror.corbina.net/pub/Linux/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso"

  headless = true
  boot_wait = "10s"
  boot_command = [
    "<tab><wait>",
    " text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/vagrant.ks<enter>"
  ]

  http_directory = "http"
  
  shutdown_timeout = "5m"
  shutdown_command = "sudo -S poweroff"
  ssh_password = "vagrant"
  ssh_pty = true
  ssh_timeout = "2h"
  ssh_username = "vagrant"

  guest_additions_mode = "upload" # this is default
  
  output_directory = "builds"
  export_opts       = [
    "--manifest",
    "--vsys", "0",
    "--description", "${var.vm_description}",
    "--version", "${var.vm_version}"
  ]
  
}

build {
  sources = [
    "source.virtualbox-iso.centos-7"
  ]

  provisioner "shell" {
    execute_command = "{{.Vars}} sudo -S -E sh '{{.Path}}'"
    expect_disconnect   = true 
    pause_before        = "20s"
    start_retry_timeout = "5m"
    scripts = [
      "scripts/stage-1-kernel-update.sh",
      "scripts/stage-1-1-install-virtualbox-guest-additions.sh",
      "scripts/stage-2-clean.sh"
    ]
  }

  post-processor "vagrant" {
    compression_level = "7"
    output            = "centos-${var.vm_version}-kernel-5-x86_64-Minimal.box"
  }
}
