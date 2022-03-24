output "vmss_public_ip_fqdn" {
  value = module.stack.vmss_public_ip_fqdn
}

output "jumpbox_public_ip_fqdn" {
  value = module.stack.jumpbox_public_ip_fqdn
}

output "jumpbox_public_ip" {
  value = module.stack.jumpbox_public_ip
}
