terraform {
  backend "s3" {
    bucket = "${bucketname}"
    key    = "${bucketkey}"
    region = "${region}"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {}

