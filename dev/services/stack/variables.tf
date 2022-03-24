variable "stack_name" {
    type = string
    default = "dev-stack"
}

variable "location" {
  default     = "centralus"
  description = "Location where resources will be created"
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    environment = "dev"
    team        = "devops"
  }
}
