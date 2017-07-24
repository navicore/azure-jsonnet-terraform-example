local nsg_rules = import "src/nsg_rules.jsonnet";
{
    local config = self,

    // variables that are used in keys of json objects need to be evaluabed by jsonnet
    env: {
        resourceGroup: std.extVar("rg"),
        vnetName: std.extVar("rg"),
    },

    // list all subnet names here
    subnets: [
        "bastion",
        "private_nodes",
        "public_nodes",
        "database",
        "cicd",
    ],

    // use subnet names above as keys for params below
    specs: {
        bastion: {
            addressPrefix: "10.0.1.0/24",
            allowIn: [
                nsg_rules.rule_allow_ssh_inet(self.addressPrefix),
                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },
        private_nodes: {
            addressPrefix: "10.0.2.0/24",
            allowIn: [
                nsg_rules.rule_allow_ssh(self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },
        public_nodes: {
            addressPrefix: "10.0.3.0/24",
            allowIn: [
                nsg_rules.rule_allow_ssh(self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },
        database: {
            addressPrefix: "10.0.4.0/24",
            allowIn: [
                nsg_rules.rule_allow_ssh(self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_allow_https_inbound(self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },
        cicd: {
            addressPrefix: "10.0.5.0/24",
            allowIn: [
                nsg_rules.rule_allow_http_8080_inbound(self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_allow_ssh(self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },

    },

}
