# ACS Email Terraform Module
# This will create an Azure Communication Services resource and configure a custom domain for email sending.

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "acs" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_communication_service" "acs" {
  name                = var.acs_name
  resource_group_name = azurerm_resource_group.acs.name
  data_location       = var.data_location
}

# Email domain setup is not yet fully supported in Terraform (as of 2025-09), so you must add and verify the domain manually in the Azure Portal after resource creation.
# See https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/communication_service

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "australiaeast"
}

variable "acs_name" {
  description = "Name of the ACS resource."
  type        = string
}

variable "data_location" {
  description = "Data location for ACS."
  type        = string
  default     = "United States"
}

output "acs_resource_id" {
  value = azurerm_communication_service.acs.id
}

output "acs_primary_connection_string" {
  value     = azurerm_communication_service.acs.primary_connection_string
  sensitive = true
}
