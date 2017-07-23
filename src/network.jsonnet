{
    // list all subnet names here
    local subnets = [
        "bastion",
        "private_nodes",
        "public_nodes",
        "database",
        "cicd",
    ],

    // use subnet names above as keys for params below
    local specs = {
        bastion: {
            addressPrefix: "10.0.1.0/24",
            allowIn: [
                rule_allow_ssh_inet("bastion"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },
        private_nodes: {
            addressPrefix: "10.0.2.0/24",
            allowIn: [
                rule_allow_ssh_bastion("private_nodes"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },
        public_nodes: {
            addressPrefix: "10.0.3.0/24",
            allowIn: [
                rule_allow_ssh_bastion("public_nodes"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },
        database: {
            addressPrefix: "10.0.4.0/24",
            allowIn: [
                rule_allow_ssh_bastion("database"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },
        cicd: {
            addressPrefix: "10.0.5.0/24",
            allowIn: [
                rule_allow_ssh_bastion("cicd"),
                rule_deny_all,
            ],
            allowOut: [
            ],
        },

    },
    // variables that are used in keys of json objects need to be evaluabed by jsonnet
    local env = {
        resourceGroup: std.extVar("rg"),
        vnetName: std.extVar("rg"),
    },

    resource: {

        // begin create network
        azurerm_virtual_network: {
            [env.vnetName]: {
                name: env.resourceGroup,
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                location: "${var.location}",
                address_space: ["10.0.0.0/8"],
            },
        },

        azurerm_network_security_group: {
            [sn + "_nsg"]: {
                name: env.resourceGroup + "-" + sn + "-nsg",
                location: "${var.location}",
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                security_rule: specs[sn].allowIn,
            } for sn in subnets
        },

        azurerm_subnet: {
            [sn + "_subnet"]: {
                name: env.resourceGroup + "-" + sn + "-subnet",
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                virtual_network_name: "${azurerm_virtual_network." + env.vnetName + ".name}",
                address_prefix: specs[sn].addressPrefix,
                network_security_group_id: "${azurerm_network_security_group." + sn + "_nsg.id}",
            } for sn in subnets
        },
    },
    local rule_allow_ssh_inet(sn) = {
        name: "allow_ssh_in_from_inet",
        priority: 100,
        direction: "Inbound",
        access: "Allow",
        protocol: "Tcp",
        source_port_range: "*",
        destination_port_range: "22",
        source_address_prefix: "INTERNET",
        destination_address_prefix: specs[sn].addressPrefix,

    },
    local rule_allow_ssh_bastion(sn) = {
        name: "allow_ssh_in_from_bastion",
        priority: 110,
        direction: "Inbound",
        access: "Allow",
        protocol: "Tcp",
        source_port_range: "*",
        destination_port_range: "22",
        source_address_prefix: specs.bastion.addressPrefix,
        destination_address_prefix: specs[sn].addressPrefix,
    },
    local rule_deny_all = {
        name: "deny_all_inbound",
        priority: 300,
        direction: "Inbound",
        access: "Deny",
        protocol: "*",
        source_port_range: "*",
        destination_port_range: "*",
        source_address_prefix: "*",
        destination_address_prefix: "*",
    },

}
