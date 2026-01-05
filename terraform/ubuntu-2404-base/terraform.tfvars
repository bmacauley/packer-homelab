# Default values for test VM
# Credentials are pulled from Vault automatically

proxmox_node  = "proxmox"
template_name = "ubuntu-2404-base"
vm_name       = "test-ubuntu-2404"
vm_id         = 999
cores         = 2
memory        = 2048
storage       = "local-lvm"
disk_size     = "10G"

# Cloud-Init
ci_user     = "ubuntu"
ci_password = "password"
