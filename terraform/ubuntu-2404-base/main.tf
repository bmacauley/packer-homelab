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
  desc        = "Test VM for ubuntu-2404-base template"
  tags        = "terraform,test"

  # Clone from template
  clone      = var.template_name
  full_clone = true
  vmid       = var.vm_id

  # OS type (l26 = Linux 2.6+ kernel)
  qemu_os = "l26"
  os_type = "cloud-init"

  # CPU
  cpu {
    cores   = var.cores
    sockets = 1
    type    = "host"
  }
  numa = false

  # Memory
  memory  = var.memory
  balloon = 0

  # BIOS
  bios = "seabios"

  # QEMU Guest Agent
  agent = 1

  # Serial console
  serial {
    id   = 0
    type = "socket"
  }

  # Display
  vga {
    type = "std"
  }

  # Network
  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  # SCSI controller
  scsihw = "virtio-scsi-pci"

  # Disks
  disks {
    scsi {
      scsi0 {
        disk {
          storage    = var.storage
          size       = var.disk_size
          discard    = true
          emulatessd = true
          iothread   = true
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.storage
        }
      }
    }
  }

  # Cloud-Init
  ipconfig0 = "ip=dhcp"
  ciuser    = "ubuntu"

  # Boot and startup
  onboot   = false
  vm_state = "running"
}
