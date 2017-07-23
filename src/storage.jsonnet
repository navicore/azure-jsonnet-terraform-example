local config = import "../config.jsonnet";
{

    resource: {

        azurerm_storage_account: {
            [config.env.resourceGroup]: {
                name: "${var.storageAccount}",
                resource_group_name: "${azurerm_resource_group." + config.env.resourceGroup + ".name}",
                location: "${var.location}",
                account_type: "Standard_LRS",
            },
        },

        azurerm_storage_container: {
            logging: {
                name: "logging",
                resource_group_name: "${azurerm_resource_group." + config.env.resourceGroup + ".name}",
                storage_account_name: "${azurerm_storage_account." + config.env.resourceGroup + ".name}",
                container_access_type: "private",
            },
            state: {
                name: "terraform-state",
                resource_group_name: "${azurerm_resource_group." + config.env.resourceGroup + ".name}",
                storage_account_name: "${azurerm_storage_account." + config.env.resourceGroup + ".name}",
                container_access_type: "private",
            },
            [config.env.resourceGroup]: {
                name: config.env.resourceGroup,
                resource_group_name: "${azurerm_resource_group." + config.env.resourceGroup + ".name}",
                storage_account_name: "${azurerm_storage_account." + config.env.resourceGroup + ".name}",
                container_access_type: "private",
            },
        },

    },
}
