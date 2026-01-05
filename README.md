# packer-homelab

Packer templates for building Proxmox VM templates in a homelab environment.

## Overview

This repository contains Packer configurations to build Ubuntu 24.04 LTS VM templates for Proxmox, along with Terraform configurations to test the built templates.

### Templates

| Template | Description | VM ID |
|----------|-------------|-------|
| `ubuntu-2404-base` | Base template with qemu-guest-agent and common utilities | 9001 |
| `ubuntu-2404-homelab` | Homelab template with Tailscale, mDNS (Avahi), and additional tools | 9002 |

### Template Hierarchy

```
ubuntu-2404-raw (Ansible-built base image)
    └── ubuntu-2404-base (Packer: adds qemu-guest-agent, serial console)
            └── ubuntu-2404-homelab (Packer: adds Tailscale, mDNS)
```

## Prerequisites

- [Packer](https://www.packer.io/) >= 1.10.0
- [Terraform](https://www.terraform.io/) >= 1.0
- [Vault](https://www.vaultproject.io/) (for credentials)
- [mise](https://mise.jdx.dev/) (optional, for tool management)
- Access to a Proxmox server

## Directory Structure

```
packer-homelab/
├── ubuntu-2404-base/           # Base template Packer config
│   ├── ubuntu-2404-base.pkr.hcl
│   ├── variables.pkrvars.hcl   # (gitignored - contains secrets)
│   └── scripts/
│       └── setup.sh
├── ubuntu-2404-homelab/        # Homelab template Packer config
│   ├── ubuntu-2404-homelab.pkr.hcl
│   ├── variables.pkrvars.hcl   # (gitignored - contains secrets)
│   └── scripts/
│       └── setup.sh
├── terraform/                  # Test VM configurations
│   ├── ubuntu-2404-base/       # Test VM for base template
│   └── ubuntu-2404-homelab/    # Test VM for homelab template
├── Makefile                    # Root Makefile for common tasks
└── CLAUDE.md                   # AI assistant guidelines
```

## Quick Start

### 1. Install Tools

```bash
# Using mise (recommended)
make install-mise-tools

# Or install manually:
# - packer
# - terraform
# - vault
```

### 2. Configure Vault

Ensure Vault is running and contains Proxmox credentials at `kv/data/proxmox`:

```bash
vault kv put kv/proxmox \
  api-url="https://proxmox.example.com:8006/api2/json" \
  api-token-id="user@pam!token-name" \
  api-token-secret="your-token-secret"
```

### 3. Create Variables File

Create `variables.pkrvars.hcl` in each template directory:

```hcl
# ubuntu-2404-base/variables.pkrvars.hcl
proxmox_node = "proxmox"
clone_vm     = "ubuntu-2404-raw"
vm_id        = 9001
```

### 4. Build Templates

```bash
# Build ubuntu-2404-base
make ubuntu-2404-base packer-init
make ubuntu-2404-base packer-build

# Build ubuntu-2404-homelab
make ubuntu-2404-homelab packer-init
make ubuntu-2404-homelab packer-build
```

### 5. Test Templates

```bash
# Test ubuntu-2404-base template
cd terraform/ubuntu-2404-base
make plan
make apply

# Access via serial console
qm terminal 999

# Clean up
make destroy
```

## Makefile Targets

### Packer Commands

```bash
make ubuntu-2404-base packer-init      # Initialize Packer plugins
make ubuntu-2404-base packer-validate  # Validate template
make ubuntu-2404-base packer-build     # Build template
make ubuntu-2404-base packer-build-force  # Rebuild (delete existing)
```

### Terraform Commands

```bash
make tf-ubuntu-2404-base tf-init    # Initialize Terraform
make tf-ubuntu-2404-base tf-plan    # Plan changes
make tf-ubuntu-2404-base tf-apply   # Apply changes
make tf-ubuntu-2404-base tf-destroy # Destroy test VM
```

### Helpers

```bash
make clean       # Remove .terraform and packer_cache directories
make clean-locks # Remove .terraform.lock.hcl files
make clean-all   # Clean everything
```

## Template Features

### ubuntu-2404-base

- QEMU Guest Agent (for Proxmox integration)
- Serial console support (for `qm terminal` access)
- Common utilities: curl, wget, vim, htop, jq, etc.
- Cloud-init ready

### ubuntu-2404-homelab

Includes everything from `ubuntu-2404-base`, plus:

- Tailscale VPN client
- mDNS/Avahi for `.local` hostname resolution
- Additional homelab tools

## Test VMs

Terraform configurations create test VMs to verify templates work correctly:

| Test VM | Template | VM ID | Name |
|---------|----------|-------|------|
| `terraform/ubuntu-2404-base` | ubuntu-2404-base | 999 | test-ubuntu-2404 |
| `terraform/ubuntu-2404-homelab` | ubuntu-2404-homelab | 998 | test-ubuntu-2404-homelab |

Each test VM includes:
- Serial console access
- Cloud-init password for console login
- DHCP networking

## Credentials

Proxmox credentials are stored in HashiCorp Vault and retrieved automatically by both Packer and Terraform.

**Required Vault secrets:**
- `kv/proxmox/api-url` - Proxmox API URL
- `kv/proxmox/api-token-id` - API token ID
- `kv/proxmox/api-token-secret` - API token secret

## License

MIT
