module "rke2_master" {
  source = "./modules/rke2-node"

  role                 = "server"
  vm_name              = var.master_vm_name
  vm_id                = var.master_vm_id
  node_name            = var.target_node
  template_vm_id       = var.template_vm_id
  cores                = var.master_cores
  memory               = var.master_memory
  disk_size            = var.vm_disk_size
  disk_datastore_id    = var.vm_disk_datastore_id
  network_bridge       = var.network_bridge
  ip_address           = var.master_ip
  gateway              = var.network_gateway
  vm_username          = var.vm_username
  ssh_public_key       = var.ssh_public_key
  ssh_private_key_path = var.ssh_private_key_path
  rke2_token           = var.rke2_token
  rke2_version         = var.rke2_version
}

module "rke2_worker" {
  source = "./modules/rke2-node"

  depends_on = [module.rke2_master]

  role                 = "agent"
  vm_name              = var.worker_vm_name
  vm_id                = var.worker_vm_id
  node_name            = var.target_node
  template_vm_id       = var.template_vm_id
  cores                = var.worker_cores
  memory               = var.worker_memory
  disk_size            = var.vm_disk_size
  disk_datastore_id    = var.vm_disk_datastore_id
  network_bridge       = var.network_bridge
  ip_address           = var.worker_ip
  gateway              = var.network_gateway
  vm_username          = var.vm_username
  ssh_public_key       = var.ssh_public_key
  ssh_private_key_path = var.ssh_private_key_path
  rke2_token           = var.rke2_token
  rke2_version         = var.rke2_version
  master_ip            = split("/", var.master_ip)[0]
}
