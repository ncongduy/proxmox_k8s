locals {
  rke2_install_env = var.rke2_version != "" ? "INSTALL_RKE2_VERSION=${var.rke2_version}" : ""
}

resource "proxmox_virtual_environment_vm" "rke2_master" {
  name        = var.master_vm_name
  description = "Managed by Terraform"
  node_name   = var.target_node
  vm_id       = var.master_vm_id

  clone {
    vm_id = var.template_vm_id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.master_cores
  }

  memory {
    dedicated = var.master_memory
  }

  disk {
    datastore_id = var.vm_disk_datastore_id
    interface    = "scsi0"
    size         = var.vm_disk_size
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    datastore_id = var.vm_disk_datastore_id

    ip_config {
      ipv4 {
        address = var.master_ip
        gateway = var.network_gateway
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
    host        = split("/", var.master_ip)[0]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y qemu-guest-agent",
      "sudo systemctl enable --now qemu-guest-agent",
      "curl -sfL https://get.rke2.io | sudo ${local.rke2_install_env} sh -",
      "sudo mkdir -p /etc/rancher/rke2",
      "echo 'token: ${var.rke2_token}' | sudo tee /etc/rancher/rke2/config.yaml > /dev/null",
      "sudo systemctl enable rke2-server.service",
      "sudo systemctl start rke2-server.service --no-block",
    ]
  }
}

resource "proxmox_virtual_environment_vm" "rke2_worker" {
  name        = var.worker_vm_name
  description = "Managed by Terraform"
  node_name   = var.target_node
  vm_id       = var.worker_vm_id

  depends_on = [proxmox_virtual_environment_vm.rke2_master]

  clone {
    vm_id = var.template_vm_id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.worker_cores
  }

  memory {
    dedicated = var.worker_memory
  }

  disk {
    datastore_id = var.vm_disk_datastore_id
    interface    = "scsi0"
    size         = var.vm_disk_size
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = var.network_bridge
  }

  initialization {
    datastore_id = var.vm_disk_datastore_id

    ip_config {
      ipv4 {
        address = var.worker_ip
        gateway = var.network_gateway
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
    host        = split("/", var.worker_ip)[0]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y qemu-guest-agent",
      "sudo systemctl enable --now qemu-guest-agent",
      "curl -sfL https://get.rke2.io | sudo ${local.rke2_install_env} INSTALL_RKE2_TYPE=agent sh -",
      "sudo mkdir -p /etc/rancher/rke2",
      "echo 'server: https://${split("/", var.master_ip)[0]}:9345' | sudo tee /etc/rancher/rke2/config.yaml > /dev/null",
      "echo 'token: ${var.rke2_token}' | sudo tee -a /etc/rancher/rke2/config.yaml > /dev/null",
      "sudo systemctl enable rke2-agent.service",
      "sudo systemctl start rke2-agent.service --no-block",
    ]
  }
}
