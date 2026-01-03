# Ubuntu 24.04 Homelab Template for Proxmox
# Clones from ubuntu-2404-base and adds homelab packages
#
# Workflow:
#   ubuntu-2404-base (Packer) → ubuntu-2404-homelab (this Packer build)

packer {
  required_version = ">= 1.10.0"

  required_plugins {
    proxmox = {
      version = ">= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# =============================================================================
# Variables
# =============================================================================

variable "vault_path" {
  type        = string
  default     = "kv/data/proxmox"
  description = "Vault path for Proxmox credentials"
}

variable "proxmox_node" {
  type        = string
  description = "Proxmox node to build on"
}

variable "proxmox_skip_tls_verify" {
  type        = bool
  default     = true
  description = "Skip TLS verification for Proxmox API"
}

variable "clone_vm" {
  type        = string
  default     = "ubuntu-2404-base"
  description = "Name of the base template to clone from"
}

variable "vm_id" {
  type        = number
  default     = 9100
  description = "VM ID for the template"
}

variable "vm_name" {
  type        = string
  default     = "ubuntu-2404-homelab"
  description = "Name of the VM template"
}

variable "template_description" {
  type        = string
  default     = "Ubuntu 24.04 LTS - Homelab template with tailscale, avahi, etc"
  description = "Description for the template"
}

variable "vm_storage_pool" {
  type        = string
  default     = "local-lvm"
  description = "Storage pool for VM disks"
}

variable "vm_cpu_cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores"
}

variable "vm_memory" {
  type        = number
  default     = 2048
  description = "Memory in MB"
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "SSH username for provisioning"
}

variable "ssh_private_key_file" {
  type        = string
  default     = "~/.ssh/id_ed25519"
  description = "Path to SSH private key for provisioning"
}

variable "ssh_timeout" {
  type        = string
  default     = "20m"
  description = "SSH connection timeout"
}

# =============================================================================
# Locals - Vault Integration
# =============================================================================

locals {
  build_timestamp          = formatdate("YYYY-MM-DD-hhmmss", timestamp())
  proxmox_api_url          = vault(var.vault_path, "api-url")
  proxmox_api_token_id     = vault(var.vault_path, "api-token-id")
  proxmox_api_token_secret = vault(var.vault_path, "api-token-secret")
}

# =============================================================================
# Source: Proxmox Clone Builder
# =============================================================================

source "proxmox-clone" "ubuntu-2404-homelab" {
  # Proxmox Connection (credentials from Vault)
  proxmox_url              = local.proxmox_api_url
  username                 = local.proxmox_api_token_id
  token                    = local.proxmox_api_token_secret
  insecure_skip_tls_verify = var.proxmox_skip_tls_verify
  node                     = var.proxmox_node

  # Clone Source
  clone_vm = var.clone_vm

  # SCSI Controller (must match source template)
  scsi_controller = "virtio-scsi-single"

  # VM General Settings
  vm_id                = var.vm_id
  vm_name              = var.vm_name
  template_description = "${var.template_description}\nBuilt: ${local.build_timestamp}"

  # VM CPU Settings
  cores    = var.vm_cpu_cores
  sockets  = 1
  cpu_type = "host"

  # VM Memory Settings
  memory = var.vm_memory

  # Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = var.vm_storage_pool

  # SSH Configuration
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = var.ssh_timeout
}

# =============================================================================
# Build
# =============================================================================

build {
  name    = "ubuntu-2404-homelab"
  sources = ["source.proxmox-clone.ubuntu-2404-homelab"]

  # Wait for cloud-init to complete
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done"
    ]
  }

  # Run setup script
  provisioner "shell" {
    scripts         = ["${path.root}/scripts/setup.sh"]
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  }

  # Clean up for template
  provisioner "shell" {
    inline = [
      "# Clean apt cache",
      "sudo apt-get -y autoremove --purge",
      "sudo apt-get -y clean",
      "sudo apt-get -y autoclean",
      "",
      "# Clear logs",
      "sudo truncate -s 0 /var/log/*.log",
      "sudo truncate -s 0 /var/log/**/*.log 2>/dev/null || true",
      "sudo rm -rf /var/log/journal/*",
      "",
      "# Clear machine-id for unique ID on clone",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "",
      "# Clear SSH host keys (will regenerate on first boot)",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "",
      "# Clear temporary files",
      "sudo rm -rf /tmp/* /var/tmp/*",
      "",
      "# Clear cloud-init for re-initialization",
      "sudo cloud-init clean --logs --seed",
      "",
      "# Clear bash history",
      "cat /dev/null > ~/.bash_history || true",
      "",
      "# Sync filesystem",
      "sync"
    ]
  }
}
