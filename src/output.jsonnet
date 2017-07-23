{
    // variables that are used in keys of json objects need to be evaluabed by jsonnet
    local env = {
        resourceGroup: std.extVar("rg"),
        vnetName: std.extVar("rg"),
    },

    output: {
        primaryAccessKey: {
            value: "${azurerm_storage_account." + env.resourceGroup + ".primary_access_key}",
        },
        resourceGroupName: {
            value: "${azurerm_resource_group." + env.resourceGroup + ".name}",
        },
        bastionFqdn: {
            value: "${azurerm_public_ip.bastion.fqdn}",
        },
    },

}
