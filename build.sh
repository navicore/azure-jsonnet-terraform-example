#!/usr/bin/env bash

DIR="$(cd `dirname $0`; pwd)"
BUILD_DIR=${DIR}/build
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

jsonnet -V ARM_CLIENT_ID -V ARM_CLIENT_SECRET -V ARM_TENANT_ID -V ARM_SUBSCRIPTION_ID -V sa=onextentmycloud -V rg=mycloud -V location=eastus src/main.jsonnet > build/main.tf.json

echo "done.  try this: \"cd ./build && terraform apply\""

