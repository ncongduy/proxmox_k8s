terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.70.0"
    }
  }
}

locals {
  rke2_install_env = var.rke2_version != "" ? "INSTALL_RKE2_VERSION=${var.rke2_version}" : ""
  host_ip          = split("/", var.ip_address)[0]

  rke2_config_server = [
    "echo 'token: ${var.rke2_token}' | sudo tee /etc/rancher/rke2/config.yaml > /dev/null",
  ]

  rke2_config_agent = [
    "echo 'server: https://${var.master_ip}:9345' | sudo tee /etc/rancher/rke2/config.yaml > /dev/null",
    "echo 'token: ${var.rke2_token}' | sudo tee -a /etc/rancher/rke2/config.yaml > /dev/null",
  ]

  rke2_install_type = var.role == "agent" ? "INSTALL_RKE2_TYPE=agent" : ""
  rke2_service      = var.role == "server" ? "rke2-server.service" : "rke2-agent.service"
  rke2_config_lines = var.role == "server" ? local.rke2_config_server : local.rke2_config_agent
}

resource "proxmox_virtual_environment_vm" "node" {
  name        = var.vm_name
  description = "Managed by Terraform"
  node_name   = var.node_name
  vm_id       = var.vm_id

  clone {
    vm_id = var.template_vm_id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.disk_datastore_id
    interface    = "scsi0"
    size         = var.disk_size
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    datastore_id = var.disk_datastore_id

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }

    user_account {
      keys     = [var.ssh_public_key]
      username = var.vm_username
    }
  }

  connection {
    type        = "ssh"
    user        = var.vm_username
    private_key = file(pathexpand(var.ssh_private_key_path))
    host        = local.host_ip
  }

  provisioner "remote-exec" {
    inline = concat(
      [
        "sudo apt-get update -y",
        "sudo apt-get install -y qemu-guest-agent",
        "sudo systemctl enable --now qemu-guest-agent",
        "curl -sfL https://get.rke2.io | sudo ${local.rke2_install_env} ${local.rke2_install_type} sh -",
        "sudo mkdir -p /etc/rancher/rke2",
      ],
      local.rke2_config_lines,
      [
        "sudo systemctl enable ${local.rke2_service}",
        "sudo systemctl start ${local.rke2_service} --no-block",
      ],
    )
  }
}
