provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"

  # Due to bug https://github.com/wata727/tflint/issues/167
  # Use github link, not terraform module registry
  # source = "git::https://github.com/SweetOps/terraform-google-storage-bucket.git?ref=v0.1.1"

  name = ["infra-tf-state-stage", "infra-tf-state-prod"]
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}
