resource "proxmox_virtual_environment_vm" "rke2_master" {
  name        = "rke2-master"
  description = "Managed by Terraform"
  node_name   = var.target_node
  vm_id       = 201

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
      username = "ubuntu"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_master.id
  }
}

resource "proxmox_virtual_environment_vm" "rke2_worker" {
  name        = "rke2-worker-1"
  description = "Managed by Terraform"
  node_name   = var.target_node
  vm_id       = 211

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
      username = "ubuntu"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_worker.id
  }
}

resource "proxmox_virtual_environment_file" "cloud_config_master" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = var.target_node

  source_raw {
    data      = <<-EOF
#cloud-config
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable --now qemu-guest-agent
  - curl -sfL https://get.rke2.io | sh -
  - mkdir -p /etc/rancher/rke2
  - echo "token: ${var.rke2_token}" > /etc/rancher/rke2/config.yaml
  - systemctl enable rke2-server.service
  - systemctl start rke2-server.service
EOF
    file_name = "rke2-master-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "cloud_config_worker" {
  content_type = "snippets"
  datastore_id = var.datastore_id
  node_name    = var.target_node

  source_raw {
    data      = <<-EOF
#cloud-config
package_update: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable --now qemu-guest-agent
  - curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
  - mkdir -p /etc/rancher/rke2
  - echo "server: https://${split("/", var.master_ip)[0]}:9345" > /etc/rancher/rke2/config.yaml
  - echo "token: ${var.rke2_token}" >> /etc/rancher/rke2/config.yaml
  - systemctl enable rke2-agent.service
  - systemctl start rke2-agent.service
EOF
    file_name = "rke2-worker-1-cloud-config.yaml"
  }
}
