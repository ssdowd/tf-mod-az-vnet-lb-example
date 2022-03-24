terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  # These cannot be variables.  
  # Note: Azure doesn't need something like a DynamoDB for locking.  Storage does that.
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstatefjbo4"
    container_name       = "tfstate"
    key                  = "ssd-vmss/stage/terraform.tfstate"
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

module "stack" {
  source               = "../../../modules/services/stack"
  stack_name           = var.stack_name
  tags                 = var.tags
  location             = var.location
  instance_count       = var.vminstances
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
  custom_data          = base64encode(file("web.conf"))
}
