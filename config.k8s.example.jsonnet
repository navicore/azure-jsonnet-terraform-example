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
                nsg_rules.rule_allow_ssh(100, self.addressPrefix, config.specs.bastion.addressPrefix),

                nsg_rules.rule_allow_k8s_http_inbound(200, self.addressPrefix, config.specs.public_nodes.addressPrefix),
                nsg_rules.rule_allow_k8s_http_inbound(201, "10.244.0.0/16", config.specs.public_nodes.addressPrefix),

                nsg_rules.rule_allow_k8s_cAdvisor_inbound(202, self.addressPrefix, config.specs.cicd.addressPrefix),
                nsg_rules.rule_allow_k8s_cAdvisor_inbound(203, "10.244.0.0/16", config.specs.cicd.addressPrefix),

                nsg_rules.rule_allow_k8s_kubelet_10250_inbound(204, self.addressPrefix, config.specs.cicd.addressPrefix),
                nsg_rules.rule_allow_k8s_kubelet_10250_inbound(205, "10.244.0.0/16", config.specs.cicd.addressPrefix),

                nsg_rules.rule_allow_k8s_kubelet_10255_inbound(206, self.addressPrefix, config.specs.cicd.addressPrefix),
                nsg_rules.rule_allow_k8s_kubelet_10255_inbound(207, "10.244.0.0/16", config.specs.cicd.addressPrefix),

                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },
        public_nodes: {
            addressPrefix: "10.0.3.0/24",
            allowIn: [
                nsg_rules.rule_allow_ssh(100, self.addressPrefix, config.specs.bastion.addressPrefix),

                nsg_rules.rule_allow_k8s_cAdvisor_inbound(200, self.addressPrefix, config.specs.cicd.addressPrefix),
                nsg_rules.rule_allow_k8s_cAdvisor_inbound(201, "10.244.0.0/16", config.specs.cicd.addressPrefix),

                nsg_rules.rule_allow_k8s_kubelet_10250_inbound(202, self.addressPrefix, config.specs.cicd.addressPrefix),
                nsg_rules.rule_allow_k8s_kubelet_10250_inbound(203, "10.244.0.0/16", config.specs.cicd.addressPrefix),

                nsg_rules.rule_allow_k8s_kubelet_10255_inbound(204, self.addressPrefix, config.specs.cicd.addressPrefix),
                nsg_rules.rule_allow_k8s_kubelet_10255_inbound(205, "10.244.0.0/16", config.specs.cicd.addressPrefix),

                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },
        database: {
            addressPrefix: "10.0.4.0/24",
            allowIn: [
                nsg_rules.rule_allow_ssh(100, self.addressPrefix, config.specs.bastion.addressPrefix),

                nsg_rules.rule_allow_https_inbound(200, self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_allow_cassandra_inbound(201, self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_allow_cassandra_inbound(202, self.addressPrefix, config.specs.private_nodes.addressPrefix),
                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },
        cicd: {
            addressPrefix: "10.0.5.0/24",
            allowIn: [
                nsg_rules.rule_allow_ssh(100, self.addressPrefix, config.specs.bastion.addressPrefix),

                nsg_rules.rule_allow_http_8080_inbound(200, self.addressPrefix, config.specs.bastion.addressPrefix),

                nsg_rules.rule_allow_https_inbound(201, self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_allow_https_inbound(202, self.addressPrefix, config.specs.public_nodes.addressPrefix),
                nsg_rules.rule_allow_https_inbound(203, self.addressPrefix, config.specs.private_nodes.addressPrefix),

                nsg_rules.rule_allow_k8s_kubedns_inbound(204, self.addressPrefix, config.specs.public_nodes.addressPrefix),

                nsg_rules.rule_allow_k8s_kubedns_inbound(205, self.addressPrefix, config.specs.private_nodes.addressPrefix),

                nsg_rules.rule_allow_etcd_2379_inbound(206, self.addressPrefix, config.specs.public_nodes.addressPrefix),
                nsg_rules.rule_allow_etcd_2380_inbound(207, self.addressPrefix, config.specs.public_nodes.addressPrefix),
                nsg_rules.rule_allow_etcd_2379_inbound(208, self.addressPrefix, config.specs.private_nodes.addressPrefix),
                nsg_rules.rule_allow_etcd_2380_inbound(209, self.addressPrefix, config.specs.private_nodes.addressPrefix),
                nsg_rules.rule_allow_k8s_kubelet_10250_inbound(210, self.addressPrefix, config.specs.private_nodes.addressPrefix),
                nsg_rules.rule_allow_k8s_kubelet_10255_inbound(211, self.addressPrefix, config.specs.private_nodes.addressPrefix),
                nsg_rules.rule_allow_k8s_kubelet_10250_inbound(212, self.addressPrefix, config.specs.public_nodes.addressPrefix),
                nsg_rules.rule_allow_k8s_kubelet_10255_inbound(213, self.addressPrefix, config.specs.public_nodes.addressPrefix),
                nsg_rules.rule_allow_k8s_dashboard_inbound(214, self.addressPrefix, config.specs.bastion.addressPrefix),
                nsg_rules.rule_deny_all,
            ],
            allowOut: [
            ],
        },

    },

}
