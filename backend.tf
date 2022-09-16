resource "aws_s3_bucket" "state_bucket" {
  force_destroy = true
  bucket_prefix = "terraform-state-"
}

locals {
  region   = "ap-southeast-2"
  statekey = "terraform.tfstate"
  provider = templatefile(
    "${path.module}/provider.tpl",
    {
      bucketname = aws_s3_bucket.state_bucket.bucket,
      bucketkey  = local.statekey,
      region     = local.region
    }
  )
}

resource "local_file" "provider" {
  content  = local.provider
  filename = "${path.module}/provider.tf"
  provisioner "local-exec" {
    command = "mv ${path.module}/temp_provider.tf temp_provider.bak"
  }
}

resource "null_resource" "migrate_state" {
  depends_on = [
    local_file.provider
  ]
  provisioner "local-exec" {
    command = "yes yes | terraform init -migrate-state -lock=false"
  }
}

output "backend" {
  value = {
    bucket = aws_s3_bucket.state_bucket.bucket
    key    = local.statekey
  }
}
