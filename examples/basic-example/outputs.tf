output "vmss_public_ip_fqdn" {
  value = module.stack.vmss_public_ip_fqdn
}

output "jumpbox_public_ip_fqdn" {
  value = module.stack.jumpbox_public_ip_fqdn
}

output "jumpbox_public_ip" {
  value = module.stack.jumpbox_public_ip
}

output "jumpbox_name" {
   value = module.stack.jumpbox_name
}

output "stack_name" {
   value = var.stack_name
}

output "resource_group" {
  value = module.stack.resource_group
}

output "instances" {
  value = module.stack.instance_count
}