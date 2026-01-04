# Terraform and Provider Requirements

terraform {
  required_version = ">= 1.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 3.0"
    }
  }
}
