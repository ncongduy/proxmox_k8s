terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.70.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure
  ssh {
    agent       = true
    username    = var.proxmox_ssh_username
    private_key = file(pathexpand(var.ssh_private_key_path))
  }
}
