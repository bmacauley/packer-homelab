# Test VM for ubuntu-2404-base template

# =============================================================================
# Providers
# =============================================================================

provider "vault" {
  # Uses VAULT_ADDR and VAULT_TOKEN from environment
  # VAULT_ADDR is set in mise.toml
}

data "vault_kv_secret_v2" "proxmox" {
  mount = "kv"
  name  = "proxmox"
}

provider "proxmox" {
  pm_api_url          = data.vault_kv_secret_v2.proxmox.data["api-url"]
  pm_api_token_id     = data.vault_kv_secret_v2.proxmox.data["api-token-id"]
  pm_api_token_secret = data.vault_kv_secret_v2.proxmox.data["api-token-secret"]
  pm_tls_insecure     = var.proxmox_tls_insecure
}

# =============================================================================
# Resources
# =============================================================================

resource "proxmox_vm_qemu" "test_vm" {
  name        = var.vm_name
  target_node = var.proxmox_node
  clone       = var.template_name
  vmid        = var.vm_id

  # CPU
  cpu {
    cores   = var.cores
    sockets = 1
    type    = "host"
  }

  # Memory
  memory = var.memory

  # QEMU Guest Agent
  agent = 1

  # Serial console
  serial {
    id   = 0
    type = "socket"
  }

  # Cloud-Init
  os_type   = "cloud-init"
  ipconfig0 = "ip=dhcp"

  # Disk
  scsihw = "virtio-scsi-single"

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.storage
          size    = var.disk_size
        }
      }
    }
  }
}
