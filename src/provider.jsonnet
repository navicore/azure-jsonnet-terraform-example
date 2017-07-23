{
    provider: {
        azurerm: {
            subscription_id: std.extVar("ARM_SUBSCRIPTION_ID"),
            client_id: std.extVar("ARM_CLIENT_ID"),
            client_secret: std.extVar("ARM_CLIENT_SECRET"),
            tenant_id: std.extVar("ARM_TENANT_ID"),
        },
    },

}
