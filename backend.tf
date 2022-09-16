locals {
  region   = "ap-southeast-2"
  statekey = "terraform.tfstate"
  lockdb   = "StateLockDB"
  provider = templatefile(
    "${path.module}/provider.tpl",
    {
      bucketname = aws_s3_bucket.state_bucket.bucket,
      bucketkey  = local.statekey,
      region     = local.region,
      lockdb     = aws_dynamodb_table.state_locking.id
    }
  )
}

resource "aws_s3_bucket" "state_bucket" {
  force_destroy = true
  bucket_prefix = "terraform-state-"
}

resource "aws_dynamodb_table" "state_locking" {
  hash_key = "LockID"
  name     = local.lockdb
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
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
    db     = aws_dynamodb_table.state_locking.id
  }
}
