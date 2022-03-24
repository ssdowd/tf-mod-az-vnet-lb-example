Example terraform module which does the following:

* works in Azure
* creates a virtual network with 1 subnet
* creates a virtual machine scale set (vmss)
* installs nginx and an example index.html using cloud-init
* puts a load balancer in front of the vmss
* creates a jump box with security group restricting ssh access to my IP
* reads a secret from azure key vault

This was derived from https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/vm-scale-set/virtual_machine_scale_set
