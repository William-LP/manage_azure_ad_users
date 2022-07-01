terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.25.0"
    }
  }
  backend "azurerm" {
    storage_account_name = ""
    resource_group_name  = ""
    container_name       = ""
    key                  = ""
    tenant_id            = ""
    subscription_id      = ""
  }

}


module "users" {
    source = "./manage_azure_ad_users"
    internal_users_csv_file = "internal.csv"
    group_projects_csv_file = "./projects"
    internal_domain = "my-domain.com"
}