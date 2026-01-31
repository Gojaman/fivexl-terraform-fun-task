terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "site_s3_cf" {
  source   = "../../modules/site_s3_cf"
  name     = "${var.project}-dev"
  region   = var.region
  site_dir = "${path.module}/../../../site"
}
