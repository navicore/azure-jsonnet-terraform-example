local config = import "../config.jsonnet";
{

    resource: {

        azurerm_virtual_network: {
            [config.env.vnetName]: {
                name: config.env.resourceGroup,
                resource_group_name: "${azurerm_resource_group." + config.env.resourceGroup + ".name}",
                location: "${var.location}",
                address_space: ["10.0.0.0/8"],
            },
        },

        azurerm_network_security_group: {
            [sn + "_nsg"]: {
                name: config.env.resourceGroup + "-" + sn + "-nsg",
                location: "${var.location}",
                resource_group_name: "${azurerm_resource_group." + config.env.resourceGroup + ".name}",
                security_rule: config.specs[sn].allowIn,
            } for sn in config.subnets
        },

        azurerm_subnet: {
            [sn + "_subnet"]: {
                name: config.env.resourceGroup + "-" + sn + "-subnet",
                resource_group_name: "${azurerm_resource_group." + config.env.resourceGroup + ".name}",
                virtual_network_name: "${azurerm_virtual_network." + config.env.vnetName + ".name}",
                address_prefix: config.specs[sn].addressPrefix,
                network_security_group_id: "${azurerm_network_security_group." + sn + "_nsg.id}",
            } for sn in config.subnets
        },
    },

}
