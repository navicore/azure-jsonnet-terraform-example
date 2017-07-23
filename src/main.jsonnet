local config = import "../config.jsonnet";
{

    resource: {

        azurerm_resource_group: {
            [config.env.resourceGroup]: {
                name: config.env.resourceGroup,
                location: "${var.location}",
            },
        },
    },
}
