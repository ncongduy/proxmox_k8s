```
# terraform output
module.rke2_worker.proxmox_virtual_environment_vm.node: Still creating... [3m10s elapsed]
module.rke2_worker.proxmox_virtual_environment_vm.node (remote-exec): (output suppressed due to sensitive value in config)
module.rke2_worker.proxmox_virtual_environment_vm.node (remote-exec): (output suppressed due to sensitive value in config)
module.rke2_worker.proxmox_virtual_environment_vm.node (remote-exec): (output suppressed due to sensitive value in config)
module.rke2_worker.proxmox_virtual_environment_vm.node: Creation complete after 3m19s [id=211]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

kubeconfig_instruction = "SSH into the master node and find the kubeconfig at /etc/rancher/rke2/rke2.yaml"
master_ip = "<MASTER_IP>/24"
worker_ip = "<WORKER_IP>/24"

# kubectl output 
$ kubectl get no -o wide
NAME            STATUS   ROLES                AGE     VERSION          INTERNAL-IP       EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
rke2-master     Ready    control-plane,etcd   7m19s   v1.34.5+rke2r1   <MASTER_IP>       <none>        Ubuntu 24.04.4 LTS   6.8.0-106-generic   containerd://2.1.5-k3s1
rke2-worker-1   Ready    <none>               4m45s   v1.34.5+rke2r1   <WORKER_IP>       <none>        Ubuntu 24.04.4 LTS   6.8.0-106-generic   containerd://2.1.5-k3s1
```
