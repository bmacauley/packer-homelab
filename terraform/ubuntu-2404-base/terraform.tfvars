# Default values for test VM
# Credentials should be set via environment variables:
#   export TF_VAR_proxmox_api_url=$(vault kv get -field=api-url kv/proxmox)
#   export TF_VAR_proxmox_api_token_id=$(vault kv get -field=api-token-id kv/proxmox)
#   export TF_VAR_proxmox_api_token_secret=$(vault kv get -field=api-token-secret kv/proxmox)

proxmox_node  = "proxmox"
template_name = "ubuntu-2404-base"
vm_name       = "test-ubuntu-2404"
vm_id         = 999
cores         = 2
memory        = 2048
storage       = "local-lvm"
disk_size     = "10G"
