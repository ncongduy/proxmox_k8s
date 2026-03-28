output "master_ip" {
  value     = proxmox_virtual_environment_vm.rke2_master.initialization[0].ip_config[0].ipv4[0].address
  sensitive = true
}

output "worker_ip" {
  value     = proxmox_virtual_environment_vm.rke2_worker.initialization[0].ip_config[0].ipv4[0].address
  sensitive = true
}

output "kubeconfig_instruction" {
  value = "SSH into the master node and find the kubeconfig at /etc/rancher/rke2/rke2.yaml"
}
