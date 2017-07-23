#!/usr/bin/env bash

DIR="$(cd `dirname $0`; pwd)"
BUILD_DIR=${DIR}/build
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

jsonnet -V ARM_CLIENT_ID -V ARM_CLIENT_SECRET -V ARM_TENANT_ID -V ARM_SUBSCRIPTION_ID -V sa=onextentmycloud -V rg=mycloud -V location=eastus src/bastion_vm.jsonnet > build/bastion_vm.tf.json
jsonnet -V ARM_CLIENT_ID -V ARM_CLIENT_SECRET -V ARM_TENANT_ID -V ARM_SUBSCRIPTION_ID -V sa=onextentmycloud -V rg=mycloud -V location=eastus src/main.jsonnet > build/main.tf.json
jsonnet -V ARM_CLIENT_ID -V ARM_CLIENT_SECRET -V ARM_TENANT_ID -V ARM_SUBSCRIPTION_ID -V sa=onextentmycloud -V rg=mycloud -V location=eastus src/network.jsonnet > build/network.tf.json
jsonnet -V ARM_CLIENT_ID -V ARM_CLIENT_SECRET -V ARM_TENANT_ID -V ARM_SUBSCRIPTION_ID -V sa=onextentmycloud -V rg=mycloud -V location=eastus src/output.jsonnet > build/output.tf.json
jsonnet -V ARM_CLIENT_ID -V ARM_CLIENT_SECRET -V ARM_TENANT_ID -V ARM_SUBSCRIPTION_ID -V sa=onextentmycloud -V rg=mycloud -V location=eastus src/provider.jsonnet > build/provider.tf.json
jsonnet -V ARM_CLIENT_ID -V ARM_CLIENT_SECRET -V ARM_TENANT_ID -V ARM_SUBSCRIPTION_ID -V sa=onextentmycloud -V rg=mycloud -V location=eastus src/storage.jsonnet > build/storage.tf.json
jsonnet -V ARM_CLIENT_ID -V ARM_CLIENT_SECRET -V ARM_TENANT_ID -V ARM_SUBSCRIPTION_ID -V sa=onextentmycloud -V rg=mycloud -V location=eastus src/variables.jsonnet > build/variables.tf.json

echo "done.  try this: \"cd ./build && terraform apply\""

