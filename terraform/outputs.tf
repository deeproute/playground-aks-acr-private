output "vm_name" {
  description = "VM Name"
  value       = module.jumpbox_vm.name
}

output "vm_id" {
  description = "VM ID"
  value       = module.jumpbox_vm.id
}

output "vm_public_ip" {
  description = "VM Public IP"
  value       = azurerm_public_ip.vm.ip_address
}

output "vm_ssh_public_key" {
  description = "If ssh_key_autogenerate is enabled, this will give the public key"
  value       = module.jumpbox_vm.ssh_public_key
}

output "vm_ssh_private_key" {
  description = "If ssh_key_autogenerate is enabled, this will give the private key"
  value       = module.jumpbox_vm.ssh_private_key
  sensitive   = true
}