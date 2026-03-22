variable "proxmox_api_url" {
  description = "The Proxmox API URL (e.g., https://192.168.1.100:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token" {
  description = "The Proxmox API Token (e.g., user@pam!tokenid=uuid)"
  type        = string
  sensitive   = true
}

variable "target_node" {
  description = "The Proxmox node where VMs will be created"
  type        = string
  default     = "pve"
}

variable "template_vm_id" {
  description = "The ID of the Cloud-init VM template to clone"
  type        = number
}

variable "ssh_public_key" {
  description = "Public SSH key to add to the VMs"
  type        = string
}

variable "rke2_token" {
  description = "The RKE2 registration token"
  type        = string
  sensitive   = true
  default     = "my-secure-rke2-token"
}

variable "network_gateway" {
  description = "The network gateway IP"
  type        = string
}

variable "master_ip" {
  description = "Static IP for the master node (e.g., 192.168.1.101/24)"
  type        = string
}

variable "worker_ips" {
  description = "Static IPs for the worker nodes"
  type        = list(string)
}
