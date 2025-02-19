resource "linode_object_storage_bucket" "default" {
  label  = var.settings.label
  region = var.settings.region
}

resource "linode_object_storage_key" "default" {
  label = var.settings.label

  bucket_access {
    bucket_name = var.settings.label
    region      = var.settings.region
    permissions = "read_write"
  }

  depends_on = [ linode_object_storage_bucket.default ]
}