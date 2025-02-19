#!/bin/bash

function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "kubeconfig is not defined! Please define it first to continue!"

    exit 1
  fi
}

function apply() {
  NAMESPACE=loki

  $HELM_CMD upgrade \
            --install loki \
            grafana/loki-distributed \
            --create-namespace \
            -n "$NAMESPACE" \
            -f ../etc/loki.yaml
}

function main() {
  checkDependencies
  apply
}

main