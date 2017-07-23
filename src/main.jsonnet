{
    // variables that are used in keys of json objects need to be evaluabed by jsonnet
    local env = {
        resourceGroup: std.extVar("rg"),
        vnetName: std.extVar("rg"),
    },

    resource: {

        azurerm_resource_group: {
            [env.resourceGroup]: {
                name: env.resourceGroup,
                location: "${var.location}",
            },
        },
    },
}
