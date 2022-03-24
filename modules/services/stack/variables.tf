variable "stack_name" {
  description = "Name for the stack to be created, used in all other names"
  default     = "myStack"
}

variable "location" {
  default     = "centralus"
  description = "Location where resources will be created"
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default     = {}
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "application_port" {
  description = "Port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  type = string
}

variable "custom_data" {
  type = string
}
