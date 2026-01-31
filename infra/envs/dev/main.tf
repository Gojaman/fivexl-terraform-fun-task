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

module "site_ec2_alb" {
  source        = "../../modules/site_ec2_alb"
  name          = "${var.project}-dev-ec2"
  region        = var.region
  site_hash     = var.ec2_site_hash
  instance_type = var.ec2_instance_type
  ssh_key_name  = var.ec2_ssh_key_name
}
