#!/usr/bin/env bash

DIR="$(cd `dirname $0`; pwd)"
BUILD_DIR=${DIR}/build

cd $BUILD_DIR && terraform apply

