{
    // variables that are used in keys of json objects need to be evaluabed by jsonnet
    local env = {
        resourceGroup: std.extVar("rg"),
        vnetName: std.extVar("rg"),
    },

    resource: {

        azurerm_public_ip: {
            bastion: {
                name: env.resourceGroup + "-bastion-pip",
                location: "${var.location}",
                resource_group_name: "${azurerm_resource_group." + env.resourceGroup + ".name}",
                public_ip_address_allocation: "static",
                domain_name_label: env.resourceGroup + "-bastion",
            },
        },

        azurerm_network_interface: {
            "bastion-nic": {
                name: env.resourceGroup + "-bastion-nic",
                location: "${var.location}",
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
                location: "${var.location}",
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
                    admin_username: "${var.vm_user}",
                    admin_password: "${uuid()}",
                },

                os_profile_linux_config: {
                    disable_password_authentication: true,
                    ssh_keys: {
                        path: "/home/${var.vm_user}/.ssh/authorized_keys",
                        key_data: "${file(var.public_key_path)}",
                    },
                },

                connection: {
                    host: "${azurerm_public_ip.bastion.fqdn}",
                    user: "${var.vm_user}",
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

    },

    data: {
        template_file: {
            bastion: {
                template: "${file(\"../files/install.sh\")}",
                vars: {
                },
            },
        },
    },

}
