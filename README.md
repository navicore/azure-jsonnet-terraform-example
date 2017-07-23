Terraform with Jsonnet for Azure VNets w/ Bastion
---------

An example of using terraform to call Azure APIs to provision a vnet with
subnets, network security groups,  and a bastion host.

# QUICK START

Create a service principal if you haven't already

```console
az ad sp create-for-rbac -n "mycloud-1-sp" --role="Contributor"
```

### set these env vars

```bash
export ARM_SUBSCRIPTION_ID=
export ARM_CLIENT_ID=
export ARM_CLIENT_SECRET=
export ARM_TENANT_ID=
```

* Generate (check for jsonnet errors)

    ```console
    ./build.sh
    ```

* Deploy (check for terraform and ARM errors)

    ```console
    ./deploy.sh
    ```

# TODO:

* get ride of `local env` and use tf variables
* refactor into multiple files
* single bash file: `build.sh` to combile the jsonnet and terraform commands

