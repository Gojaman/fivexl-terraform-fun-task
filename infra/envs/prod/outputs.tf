output "s3_cf_url" {
  value = module.site_s3_cf.url
}

output "s3_bucket" {
  value = module.site_s3_cf.bucket_name
}

output "ec2_alb_url" {
  value = module.site_ec2_alb.alb_url
}
