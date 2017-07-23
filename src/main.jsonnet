{
    // variables that are used in keys of json objects need to be evaluabed by jsonnet
    local env = {
        resourceGroup: std.extVar("rg"),
        vnetName: std.extVar("rg"),
    },

    variable: {
        subscriptionId: { default: std.extVar("ARM_SUBSCRIPTION_ID") },
        storageAccount: { default: std.extVar("sa") },
        location: { default: std.extVar("location") },
        private_key_path: { default: "~/mycloudkeys/id_rsa" },
        public_key_path: { default: "~/mycloudkeys/id_rsa.pub" },
        vm_user: { default: "localadmin" },
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
