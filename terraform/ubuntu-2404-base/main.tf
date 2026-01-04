# Test VM for ubuntu-2404-base template

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = var.proxmox_tls_insecure
}

resource "proxmox_vm_qemu" "test_vm" {
  name        = var.vm_name
  target_node = var.proxmox_node
  clone       = var.template_name
  vmid        = var.vm_id

  # CPU
  cores   = var.cores
  sockets = 1

  # Memory
  memory = var.memory

  # QEMU Guest Agent
  agent = 1

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
