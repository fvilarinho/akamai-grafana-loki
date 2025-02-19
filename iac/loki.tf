locals {
  applyLokiScriptFilename = abspath(pathexpand("./applyLoki.sh"))
}

resource "local_file" "lokiSettings" {
  filename = abspath(pathexpand("../etc/loki.yaml"))
  content = <<EOT
loki:
  ingester:
    chunk_idle_period: 10s
    max_chunk_age: 30s
    chunk_target_size: 1048576  # 1MB

  schemaConfig:
    configs:
    - from: 2020-09-07
      store: boltdb-shipper
      object_store: s3
      schema: v11
      index:
        prefix: loki_index_
        period: 24h

  storageConfig:
    boltdb_shipper:
      shared_store: s3
      active_index_directory: /var/loki/index
      cache_location: /var/loki/cache
      cache_ttl: 168h
    aws:
      s3: s3://${linode_object_storage_key.default.access_key}:${linode_object_storage_key.default.secret_key}@${var.settings.region}-1.linodeobjects.com/${var.settings.label}
      s3forcepathstyle: true
EOT
}

resource "null_resource" "applyLoki" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = abspath(pathexpand(var.settings.kubeconfig))
    }

    command = local.applyLokiScriptFilename
  }

  depends_on = [
    linode_object_storage_bucket.default,
    linode_object_storage_key.default,
    local_file.lokiSettings
  ]
}