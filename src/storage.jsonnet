{
    // variables that are used in keys of json objects need to be evaluabed by jsonnet
    local env = {
        resourceGroup: std.extVar("rg"),
        vnetName: std.extVar("rg"),
    },

    resource: {

        azurerm_storage_account: {
            [env.resourceGroup]: {
                name: "${var.storageAccount}",
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                location: "${var.location}",
                account_type: "Standard_LRS",
            },
        },

        azurerm_storage_container: {
            logging: {
                name: "logging",
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                storage_account_name: "${azurerm_storage_account." + env.resourceGroup + ".name}",
                container_access_type: "private",
            },
            state: {
                name: "terraform-state",
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                storage_account_name: "${azurerm_storage_account." + env.resourceGroup + ".name}",
                container_access_type: "private",
            },
            [env.resourceGroup]: {
                name: env.resourceGroup,
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                storage_account_name: "${azurerm_storage_account." + env.resourceGroup + ".name}",
                container_access_type: "private",
            },
        },

    },
}
