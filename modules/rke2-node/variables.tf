variable "role" {
  description = "The RKE2 role: 'server' for master or 'agent' for worker"
  type        = string

  validation {
    condition     = contains(["server", "agent"], var.role)
    error_message = "role must be either 'server' or 'agent'."
  }
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_id" {
  description = "Proxmox VM ID"
  type        = number
}

variable "node_name" {
  description = "Proxmox node to create the VM on"
  type        = string
}

variable "template_vm_id" {
  description = "VM ID of the cloud-init template to clone"
  type        = number
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
}

variable "memory" {
  description = "Dedicated memory in MB"
  type        = number
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
}

variable "disk_datastore_id" {
  description = "Proxmox datastore for the VM disk"
  type        = string
}

variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
}

variable "ip_address" {
  description = "Static IP in CIDR notation (e.g., 192.168.1.101/24)"
  type        = string
}

variable "gateway" {
  description = "Network gateway IP"
  type        = string
}

variable "vm_username" {
  description = "Username created on the VM via cloud-init"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key added to the VM"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for provisioning"
  type        = string
}

variable "rke2_token" {
  description = "RKE2 cluster registration token"
  type        = string
  sensitive   = true
}

variable "rke2_version" {
  description = "RKE2 version to install (empty string for latest)"
  type        = string
  default     = ""
}

variable "master_ip" {
  description = "Master node IP (without CIDR). Required when role is 'agent'."
  type        = string
  default     = ""
}
