resource "proxmox_virtual_environment_vm" "rke2_master" {
  name        = "rke2-master"
  description = "Managed by Terraform"
  node_name   = var.target_node
  vm_id       = 201

  clone {
    vm_id = var.template_vm_id
  }

  agent {
    enabled = false
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
    bridge = "vmbr0"
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
      username = "devops"
    }
  }

  connection {
    type        = "ssh"
    user        = "devops"
    private_key = file(pathexpand("~/.ssh/id_rsa"))
    host        = split("/", var.master_ip)[0]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y qemu-guest-agent",
      "sudo systemctl enable --now qemu-guest-agent",
      "curl -sfL https://get.rke2.io | sudo sh -",
      "sudo mkdir -p /etc/rancher/rke2",
      "echo 'token: ${var.rke2_token}' | sudo tee /etc/rancher/rke2/config.yaml",
      "sudo systemctl enable rke2-server.service",
      "sudo systemctl start rke2-server.service --no-block",
    ]
  }
}

resource "proxmox_virtual_environment_vm" "rke2_worker" {
  name        = "rke2-worker-1"
  description = "Managed by Terraform"
  node_name   = var.target_node
  vm_id       = 211

  depends_on = [proxmox_virtual_environment_vm.rke2_master]

  clone {
    vm_id = var.template_vm_id
  }

  agent {
    enabled = false
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
    bridge = "vmbr0"
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
      username = "devops"
    }
  }

  connection {
    type        = "ssh"
    user        = "devops"
    private_key = file(pathexpand("~/.ssh/id_rsa"))
    host        = split("/", var.worker_ip)[0]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y qemu-guest-agent",
      "sudo systemctl enable --now qemu-guest-agent",
      "curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_TYPE=agent sh -",
      "sudo mkdir -p /etc/rancher/rke2",
      "echo 'server: https://${split("/", var.master_ip)[0]}:9345' | sudo tee /etc/rancher/rke2/config.yaml",
      "echo 'token: ${var.rke2_token}' | sudo tee -a /etc/rancher/rke2/config.yaml",
      "sudo systemctl enable rke2-agent.service",
      "sudo systemctl start rke2-agent.service --no-block",
    ]
  }
}
