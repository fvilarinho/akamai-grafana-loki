#!/bin/bash

function checkDependencies() {
  export KUBECONFIG="$1"

  if [ -z "$KUBECONFIG" ]; then
    echo "kubeconfig is not defined! Please define it first to continue!"

    exit 1
  fi
}

function prepareToExecute() {
  export KUBECTL_CMD=$(which kubectl)
  export LINODE_CLI_CMD=$(which linode-cli)
  export JQ_CMD=$(which jq)
}

function fetchEndpoints() {
  NAMESPACE=grafana
  GRAFANA_IP=$($KUBECTL_CMD get svc grafana-lb -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[].ip}')
  GRAFANA_ENDPOINT=http://$GRAFANA_IP
  GRAFANA_USER=admin
  GRAFANA_PASSWORD=$($KUBECTL_CMD get secret grafana -n "$NAMESPACE" -o jsonpath='{.data.admin-password}' | base64 -d)
  GRAFANA_LB_ID=$($LINODE_CLI_CMD nodebalancers list --ipv4 "$GRAFANA_IP" --json | $JQ_CMD -r '.[].id')

  NAMESPACE=loki
  LOKI_INGEST_IP=$($KUBECTL_CMD get svc loki-lb -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[].ip}')
  LOKI_INGEST_ENDPOINT=http://$LOKI_INGEST_IP:3100/loki/api/v1/push
  LOKI_INGEST_LB_ID=$($LINODE_CLI_CMD nodebalancers list --ipv4 "$LOKI_INGEST_IP" --json | $JQ_CMD -r '.[].id')

  echo "{\"grafanaLoadBalancerId\": \"$GRAFANA_LB_ID\",
         \"grafanaEndpoint\": \"$GRAFANA_ENDPOINT\",
         \"grafanaUser\": \"$GRAFANA_USER\",
         \"grafanaPassword\": \"$GRAFANA_PASSWORD\",
         \"lokiIngestLoadBalancerId\": \"$LOKI_INGEST_LB_ID\",
         \"lokiIngestEndpoint\": \"$LOKI_INGEST_ENDPOINT\"}"
}

function main() {
  checkDependencies "$1"
  prepareToExecute
  fetchEndpoints
}

main "$1"