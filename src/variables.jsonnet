{

    variable: {
        subscriptionId: { default: std.extVar("ARM_SUBSCRIPTION_ID") },
        storageAccount: { default: std.extVar("sa") },
        location: { default: std.extVar("location") },
        private_key_path: { default: "~/mycloudkeys/id_rsa" },
        public_key_path: { default: "~/mycloudkeys/id_rsa.pub" },
        vm_user: { default: "localadmin" },
    },

}
