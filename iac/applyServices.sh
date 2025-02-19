#!/bin/bash

function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "kubeconfig is not defined! Please define it first to continue!"

    exit 1
  fi
}

function apply() {
  $KUBECTL_CMD apply -f services.yaml
}

function main() {
  checkDependencies
  apply
}

main