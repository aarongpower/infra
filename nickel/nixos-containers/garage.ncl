let common = {
  name           = "garage",
  location       = "Australia East",
  vaultName      = "kv-garage",
  apiSecretName  = "garage-admin-key",
  containerPort  = 3900,
};

{
  terraform = {
    provider.azurerm.features = { };

    data.azurerm_client_config.current = { };

    resource = {
      azurerm_resource_group.rg = {
        name     = "rg-${common.name}",
        location = common.location,
      },
      
      azurerm_key_vault.kv = {
        name                        = common.vaultName,
        location                    = "%{azurerm_resource_group.rg.location}",
        resource_group_name         = "%{azurerm_resource_group.rg.name}",
        enabled_for_disk_encryption = true,
        tenant_id                   = "%{data.azurerm_client_config.current.tenant_id}",
        soft_delete_retention_days  = 7,
        purge_protection_enabled    = false,
        sku_name                    = "standard",
        
        access_policy = {
          tenant_id = "%{data.azurerm_client_config.current.tenant_id}",
          object_id = "%{data.azurerm_client_config.current.object_id}",
          
          key_permissions = [
            "Create",
            "Get",
          ],
          
          secret_permissions = [
            "Set",
            "Get",
            "Delete",
            "Purge",
            "Recover",
          ],
        },
      },
      
      random_password.garage_admin_key = {
        length           = 32,
        special          = true,
        override_special = "!#$%&*()-_=+[]{}<>:?",
      },
      
      azurerm_key_vault_secret.admin_key = {
        name         = common.apiSecretName,
        value        = "%{random_password.garage_admin_key.result}",
        key_vault_id = "%{azurerm_key_vault.kv.id}",
      },
    },
  },
}