resource "proxmox_virtual_environment_vm" "rke2_master" {
  name        = "rke2-master"
  description = "Managed by Terraform"
  node_name   = var.target_node
  vm_id       = 201

  clone {
    vm_id = var.template_vm_id
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
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
  count       = 2
  name        = "rke2-worker-${count.index + 1}"
  description = "Managed by Terraform"
  node_name   = var.target_node
  vm_id       = 211 + count.index

  clone {
    vm_id = var.template_vm_id
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.worker_ips[count.index]
        gateway = var.network_gateway
      }
    }

    user_account {
      keys     = [var.ssh_public_key]
      username = "ubuntu"
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config_worker[count.index].id
  }
}

resource "proxmox_virtual_environment_file" "cloud_config_master" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data = <<-EOF
    #cloud-config
    runcmd:
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
  count        = 2
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.target_node

  source_raw {
    data = <<-EOF
    #cloud-config
    runcmd:
      - curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
      - mkdir -p /etc/rancher/rke2
      - echo "server: https://${split("/", var.master_ip)[0]}:9345" > /etc/rancher/rke2/config.yaml
      - echo "token: ${var.rke2_token}" >> /etc/rancher/rke2/config.yaml
      - systemctl enable rke2-agent.service
      - systemctl start rke2-agent.service
    EOF
    file_name = "rke2-worker-${count.index + 1}-cloud-config.yaml"
  }
}
