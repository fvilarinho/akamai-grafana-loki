#!/bin/bash

function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "kubeconfig is not defined! Please define it first to continue!"

    exit 1
  fi
}

function apply() {
  NAMESPACE=grafana

  $HELM_CMD install grafana \
            grafana/grafana \
            --namespace "$NAMESPACE" \
            --create-namespace
}

function main() {
  checkDependencies
  apply
}

main