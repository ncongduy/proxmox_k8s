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

variable "datastore_id" {
  description = "The Proxmox datastore where snippets will be stored"
  type        = string
  default     = "local"
}

variable "vm_disk_datastore_id" {
  description = "The Proxmox datastore where VM disks will be created"
  type        = string
  default     = "local-lvm"
}

variable "template_vm_id" {
  description = "The VM ID of the Ubuntu cloud image template to clone from"
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
}

variable "network_gateway" {
  description = "The network gateway IP"
  type        = string
}

variable "master_ip" {
  description = "Static IP for the master node (e.g., 192.168.1.101/24)"
  type        = string
}

variable "worker_ip" {
  description = "Static IP for the worker node (e.g., 192.168.1.102/24)"
  type        = string
}

variable "proxmox_ssh_username" {
  description = "SSH username for the Proxmox node"
  type        = string
  default     = "root"
}

variable "master_cores" {
  description = "CPU cores for the master node"
  type        = number
  default     = 2
}

variable "master_memory" {
  description = "Memory in MB for the master node"
  type        = number
  default     = 4096
}

variable "worker_cores" {
  description = "CPU cores for each worker node"
  type        = number
  default     = 2
}

variable "worker_memory" {
  description = "Memory in MB for each worker node"
  type        = number
  default     = 4096
}

variable "vm_disk_size" {
  description = "Disk size for each VM in GB"
  type        = number
  default     = 20
}
