# Outputs for test VM

output "vm_id" {
  description = "The VM ID"
  value       = proxmox_vm_qemu.test_vm.vmid
}

output "vm_name" {
  description = "The VM name"
  value       = proxmox_vm_qemu.test_vm.name
}

output "vm_node" {
  description = "The Proxmox node the VM is running on"
  value       = proxmox_vm_qemu.test_vm.target_node
}
