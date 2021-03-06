variable "stack_name" {
  type    = string
  default = "dev-stack"
}

variable "location" {
  default     = "centralus"
  description = "Location where resources will be created"
}

variable "vminstances" {
  default = 1
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    environment = "dev"
    team        = "devops"
  }
}

variable "my_cidr" {
  default = "0.0.0.0/0"
}
