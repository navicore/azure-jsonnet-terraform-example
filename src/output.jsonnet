local config = import "../config.jsonnet";
{

    output: {
        primaryAccessKey: {
            value: "${azurerm_storage_account." + config.env.resourceGroup + ".primary_access_key}",
        },
        resourceGroupName: {
            value: "${azurerm_resource_group." + config.env.resourceGroup + ".name}",
        },
        bastionFqdn: {
            value: "${azurerm_public_ip.bastion.fqdn}",
        },
    },

}
