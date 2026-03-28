variable "proxmox_api_url" {
  description = "The Proxmox API URL (e.g., https://192.168.1.100:8006/api2/json)"
  type        = string

  validation {
    condition     = can(regex("^https://", var.proxmox_api_url))
    error_message = "The Proxmox API URL must start with https://."
  }
}

variable "proxmox_api_token" {
  description = "The Proxmox API Token (e.g., user@pam!tokenid=uuid)"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Whether to skip TLS verification for the Proxmox API"
  type        = bool
  default     = true
}

variable "target_node" {
  description = "The Proxmox node where VMs will be created"
  type        = string
  default     = "pve"
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

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for provisioning"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "rke2_token" {
  description = "The RKE2 registration token"
  type        = string
  sensitive   = true
}

variable "rke2_version" {
  description = "The RKE2 version to install (e.g., v1.32.4+rke2r1). Leave empty to install latest."
  type        = string
  default     = ""
}

variable "network_gateway" {
  description = "The network gateway IP"
  type        = string
}

variable "network_bridge" {
  description = "The Proxmox network bridge to attach VMs to"
  type        = string
  default     = "vmbr0"
}

variable "master_vm_id" {
  description = "The VM ID for the master node"
  type        = number
  default     = 201
}

variable "master_vm_name" {
  description = "The VM name for the master node"
  type        = string
  default     = "rke2-master"
}

variable "master_ip" {
  description = "Static IP for the master node in CIDR notation (e.g., 192.168.1.101/24)"
  type        = string

  validation {
    condition     = can(regex("^\\d{1,3}(\\.\\d{1,3}){3}/\\d{1,2}$", var.master_ip))
    error_message = "The master_ip must be in CIDR notation (e.g., 192.168.1.101/24)."
  }
}

variable "worker_vm_id" {
  description = "The VM ID for the worker node"
  type        = number
  default     = 211
}

variable "worker_vm_name" {
  description = "The VM name for the worker node"
  type        = string
  default     = "rke2-worker-1"
}

variable "worker_ip" {
  description = "Static IP for the worker node in CIDR notation (e.g., 192.168.1.102/24)"
  type        = string

  validation {
    condition     = can(regex("^\\d{1,3}(\\.\\d{1,3}){3}/\\d{1,2}$", var.worker_ip))
    error_message = "The worker_ip must be in CIDR notation (e.g., 192.168.1.102/24)."
  }
}

variable "vm_username" {
  description = "The username to create on the VMs via cloud-init"
  type        = string
  default     = "devops"
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

  validation {
    condition     = var.master_cores >= 1
    error_message = "master_cores must be at least 1."
  }
}

variable "master_memory" {
  description = "Memory in MB for the master node"
  type        = number
  default     = 4096

  validation {
    condition     = var.master_memory >= 2048
    error_message = "master_memory must be at least 2048 MB for RKE2."
  }
}

variable "worker_cores" {
  description = "CPU cores for each worker node"
  type        = number
  default     = 2

  validation {
    condition     = var.worker_cores >= 1
    error_message = "worker_cores must be at least 1."
  }
}

variable "worker_memory" {
  description = "Memory in MB for each worker node"
  type        = number
  default     = 4096

  validation {
    condition     = var.worker_memory >= 2048
    error_message = "worker_memory must be at least 2048 MB for RKE2."
  }
}

variable "vm_disk_size" {
  description = "Disk size for each VM in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.vm_disk_size >= 10
    error_message = "vm_disk_size must be at least 10 GB."
  }
}
