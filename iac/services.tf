locals {
  applyServicescriptFilename   = abspath(pathexpand("./applyServices.sh"))
  fetchEndpointsScriptFilename = abspath(pathexpand("./fetchEndpoints.sh"))
  readmeFilename               = abspath(pathexpand("../README.txt"))
  testScriptFilename           = abspath(pathexpand("../bin/test.sh"))
}

resource "null_resource" "applyServices" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = abspath(pathexpand(var.settings.kubeconfig))
    }

    command = local.applyServicescriptFilename
  }

  depends_on = [
    null_resource.applyLoki,
    null_resource.applyGrafana
  ]
}

data "external" "fetchEndpoints" {
  program = [
    local.fetchEndpointsScriptFilename,
    abspath(pathexpand(var.settings.kubeconfig))
  ]

  depends_on = [
    null_resource.applyGrafana,
    null_resource.applyServices
  ]
}

resource "local_file" "readme" {
  filename = local.readmeFilename
  content = <<EOT
+-------------------------------------------------+
| WELCOME TO GRAFANA LOKI + AKAMAI OBJECT STORAGE |
+-------------------------------------------------+

To access Grafana, just browse the URL: ${data.external.fetchEndpoints.result.grafanaEndpoint}

Follow the default credentials below:
user: ${data.external.fetchEndpoints.result.grafanaUser}
password: ${data.external.fetchEndpoints.result.grafanaPassword}

To add Loki datasource in Grafana, the URL is: http://loki-loki-distributed-query-frontend.loki.svc.cluster.local:3100
and to ingest data in Loki, just do a POST request in the URL: ${data.external.fetchEndpoints.result.lokiIngestEndpoint}
as following:

curl -v \
     -X POST ${data.external.fetchEndpoints.result.lokiIngestEndpoint} \
     -H "Content-Type: application/json" \
     -d "{
           \"streams\": [
             {
               \"stream\": {
                 \"job\": \"myapp\",
                 \"host\": \"myhost\"
               },
               \"values\": [
                 [ \"<timestamp>\", \"<message>\" ]
               ]
             }
           ]
         }"
EOT

  depends_on = [ data.external.fetchEndpoints ]
}

resource "local_file" "testScript" {
  filename = local.testScriptFilename
  file_permission = "0700"
  content = <<EOT
#!/bin/bash

while true; do
  timestamp=$(gdate +%s%N)

  curl -v \
       -X POST ${data.external.fetchEndpoints.result.lokiIngestEndpoint} \
       -H "Content-Type: application/json" \
       -d "{
             \"streams\": [
               {
                 \"stream\": {
                   \"job\": \"myapp\",
                   \"host\": \"myhost\"
                 },
                 \"values\": [
                   [ \"$timestamp\", \"Hello Loki!\" ]
                 ]
               }
             ]
           }"

  sleep 1
done
EOT

  depends_on = [ data.external.fetchEndpoints ]
}