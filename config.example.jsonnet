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
                nsg_rules.rule_allow_k8s_http_inbound(config.specs.public_nodes.addressPrefix),
                nsg_rules.rule_allow_etcd_2379_inbound(self.addressPrefix, config.specs.public_nodes.addressPrefix),
                nsg_rules.rule_allow_etcd_2380_inbound(self.addressPrefix, config.specs.public_nodes.addressPrefix),
                nsg_rules.rule_allow_k8s_cAdvisor_4194_inbound(config.specs.cicd.addressPrefix),
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
                nsg_rules.rule_allow_cassandra_inbound(self.addressPrefix, config.specs.private_nodes.addressPrefix),
                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },
        cicd: {
            addressPrefix: "10.0.5.0/24",
            allowIn: [
                nsg_rules.rule_allow_ssh(self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },

    },

}
