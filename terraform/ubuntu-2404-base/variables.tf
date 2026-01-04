# Variables for Proxmox Test VM

# =============================================================================
# Proxmox Connection
# =============================================================================

variable "proxmox_api_url" {
  type        = string
  description = "Proxmox API URL (e.g., https://proxmox:8006/api2/json)"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token ID (e.g., user@pam!tokenname)"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Proxmox API token secret"
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  type        = bool
  default     = true
  description = "Skip TLS verification for self-signed certificates"
}

# =============================================================================
# VM Configuration
# =============================================================================

variable "proxmox_node" {
  type        = string
  default     = "proxmox"
  description = "Proxmox node to deploy on"
}

variable "template_name" {
  type        = string
  default     = "ubuntu-2404-base"
  description = "Name of the template to clone from"
}

variable "vm_name" {
  type        = string
  default     = "test-ubuntu-2404"
  description = "Name for the test VM"
}

variable "vm_id" {
  type        = number
  default     = 999
  description = "VM ID for the test VM"
}

variable "cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores"
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Memory in MB"
}

variable "storage" {
  type        = string
  default     = "local-lvm"
  description = "Storage pool for VM disk"
}

variable "disk_size" {
  type        = string
  default     = "10G"
  description = "Disk size for the VM"
}
