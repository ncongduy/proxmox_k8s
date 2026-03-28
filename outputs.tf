output "master_ip" {
  value     = module.rke2_master.ip_address
  sensitive = true
}

output "worker_ip" {
  value     = module.rke2_worker.ip_address
  sensitive = true
}

output "kubeconfig_instruction" {
  value = "SSH into the master node and find the kubeconfig at /etc/rancher/rke2/rke2.yaml"
}
