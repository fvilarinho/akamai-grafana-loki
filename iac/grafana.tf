locals {
  applyGrafanaScriptFilename = abspath(pathexpand("./applyGrafana.sh"))
}

resource "null_resource" "applyGrafana" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = abspath(pathexpand(var.settings.kubeconfig))
    }

    command = local.applyGrafanaScriptFilename
  }

  depends_on = [
    null_resource.applyLoki
  ]
}