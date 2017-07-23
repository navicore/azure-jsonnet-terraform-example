{
    /**
      dependencies: brew install jsonnet

      to generate terraform subnets.tf.json run:

      jsonnet -V ARM_SUBSCRIPTION_ID -V rg=mycloud -V location=eastus network.jsonnet > network.tf.json
    */

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
    //
    // PARAMS END
    //

    //
    // PARAMS BEGIN
    //

    //todo replace with variable.jsonnet so that each file doesn't have to have a local env var
    //todo replace with variable.jsonnet so that each file doesn't have to have a local env var
    //todo replace with variable.jsonnet so that each file doesn't have to have a local env var
    //todo replace with variable.jsonnet so that each file doesn't have to have a local env var
    //todo replace with variable.jsonnet so that each file doesn't have to have a local env var
    //todo replace with variable.jsonnet so that each file doesn't have to have a local env var
    //todo replace with variable.jsonnet so that each file doesn't have to have a local env var
    //todo replace with variable.jsonnet so that each file doesn't have to have a local env var
    //todo replace with variable.jsonnet so that each file doesn't have to have a local env var
    local env = {
        vm_user: "localadmin",
        private_key_path: "mycloudkeys/id_rsa",
        public_key_path: "mycloudkeys/id_rsa.pub",
        location: std.extVar("location"),
        resourceGroup: std.extVar("rg"),
        storageAccount: std.extVar("sa"),
        vnetName: std.extVar("rg"),
        subscriptionId: std.extVar("ARM_SUBSCRIPTION_ID"),
    },

    provider: {
        azurerm: {
            subscription_id: std.extVar("ARM_SUBSCRIPTION_ID"),
            client_id: std.extVar("ARM_CLIENT_ID"),
            client_secret: std.extVar("ARM_CLIENT_SECRET"),
            tenant_id: std.extVar("ARM_TENANT_ID"),
        },
    },

    variable: {
        private_key_path: { default: "~/mycloudkeys/id_rsa" },
        public_key_path: { default: "~/mycloudkeys/id_rsa.pub" },
    },

    //
    // PROCESSING BEGINS
    //
    resource: {

        azurerm_resource_group: {
            [env.resourceGroup]: {
                name: env.resourceGroup,
                location: env.location,
            },
        },

        // begin create network
        azurerm_virtual_network: {
            [env.vnetName]: {
                name: env.resourceGroup,
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                location: env.location,
                address_space: ["10.0.0.0/8"],
            },
        },

        azurerm_network_security_group: {
            [sn + "_nsg"]: {
                name: env.resourceGroup + "-" + sn + "-nsg",
                location: env.location,
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
        // end create network

        // begin storage
        azurerm_storage_account: {
            [env.resourceGroup]: {
                name: env.storageAccount,
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                location: env.location,
                account_type: "Standard_LRS",
            },
        },

        azurerm_storage_container: {
            logging: {
                name: "logging",
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                storage_account_name: "${azurerm_storage_account." + env.resourceGroup + ".name}",
                container_access_type: "private",
            },
            state: {
                name: "terraform-state",
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                storage_account_name: "${azurerm_storage_account." + env.resourceGroup + ".name}",
                container_access_type: "private",
            },
            [env.resourceGroup]: {
                name: env.resourceGroup,
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                storage_account_name: "${azurerm_storage_account." + env.resourceGroup + ".name}",
                container_access_type: "private",
            },
        },
        // end storage

        // begin bastion
        azurerm_public_ip: {
            bastion: {
                name: env.resourceGroup + "-bastion-pip",
                location: env.location,
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                public_ip_address_allocation: "static",
                domain_name_label: env.resourceGroup + "-bastion",
            },
        },

        azurerm_network_interface: {
            "bastion-nic": {
                name: env.resourceGroup + "-bastion-nic",
                location: env.location,
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                network_security_group_id: "${azurerm_network_security_group.bastion_nsg.id}",
                ip_configuration: [{
                    name: env.resourceGroup + "-bastion",
                    private_ip_address_allocation: "static",
                    private_ip_address: "10.0.1.5",
                    subnet_id: "${azurerm_subnet.bastion_subnet.id}",
                    public_ip_address_id: "${azurerm_public_ip.bastion.id}",
                }],

            },
        },

        azurerm_virtual_machine: {
            bastion: {
                name: "${azurerm_resource_group." + env.resourceGroup + ".name}-bastion",
                location: "${azurerm_resource_group." + env.resourceGroup + ".location}",
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                network_interface_ids: ["${azurerm_network_interface.bastion-nic.id}"],
                vm_size: "Standard_D11_V2",
                delete_os_disk_on_termination: true,

                lifecycle: {
                    ignore_changes: ["admin_password"],
                },
                storage_image_reference:
                    {
                        publisher: "OpenLogic",
                        offer: "CentOS",
                        sku: "7.2",
                        version: "latest",
                    },

                storage_os_disk: {
                    name: "${azurerm_resource_group." + env.resourceGroup + ".name}-bastion",
                    vhd_uri: "${azurerm_storage_account." + env.resourceGroup + ".primary_blob_endpoint}${azurerm_storage_container." + env.resourceGroup + ".name}/bastion_os_disk.vhd",
                    caching: "ReadWrite",
                    create_option: "FromImage",
                },

                os_profile: {
                    computer_name: "${azurerm_resource_group." + env.resourceGroup + ".name}-bastion",
                    admin_username: env.vm_user,
                    admin_password: "${uuid()}",
                },

                os_profile_linux_config: {
                    disable_password_authentication: true,
                    ssh_keys: {
                        path: "/home/" + env.vm_user + "/.ssh/authorized_keys",
                        key_data: "${file(var.public_key_path)}",
                    },
                },

                connection: {
                    host: "${azurerm_public_ip.bastion.fqdn}",
                    user: env.vm_user,
                    private_key: "${file(var.private_key_path)}",
                },

                provisioner: {
                    "remote-exec": {
                        inline: [
                            "${data.template_file.bastion.rendered}",
                        ],
                    },
                },

            },
        },


        // end bastion
    },

    data: {
        template_file: {
            bastion: {
                template: "${file(\"files/install.sh\")}",
                vars: {
                },
            },
        },
    },

    output: {
        primaryAccessKey: {
            value: "${azurerm_storage_account." + env.resourceGroup + ".primary_access_key}",
        },
        resourceGroupName: {
            value: "${azurerm_resource_group." + env.resourceGroup + ".name}",
        },
        bastionFqdn: {
            value: "${azurerm_public_ip.bastion.fqdn}",
        },
    },

    //
    // RULES BEGIN
    //
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
    //
    // RULES END
    //

}
