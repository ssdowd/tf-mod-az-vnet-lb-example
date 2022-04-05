terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  # We'll use a local backend for testing.
  backend "local" {}

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

module "stack" {
#  source               = "git@github.com:ssdowd/tf-mod-az-vnet-lb-example.git//modules/services/stack?ref=azure-pipelines"
  source               = "../../modules/services/stack"
  stack_name           = var.stack_name
  tags                 = var.tags
  location             = var.location
  instance_count       = var.vminstances
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
  custom_data          = base64encode(templatefile("web.tftpl", { stackname = var.stack_name }))
}
