output "vmss_public_ip_fqdn" {
   value = azurerm_public_ip.vmss.fqdn
}

output "jumpbox_public_ip_fqdn" {
   value = azurerm_public_ip.jumpbox.fqdn
}

output "jumpbox_public_ip" {
   value = azurerm_public_ip.jumpbox.ip_address
}

output "jumpbox_name" {
   value = azurerm_public_ip.jumpbox.name
}
output "stack_name" {
   value = var.stack_name
}

output "resource_group" {
   value = azurerm_resource_group.vmss
}

output "instance_count" {
   value = azurerm_linux_virtual_machine_scale_set.vmss.instances
}
