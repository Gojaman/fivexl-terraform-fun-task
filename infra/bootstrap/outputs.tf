output "tfstate_bucket" {
  value       = aws_s3_bucket.tfstate.bucket
  description = "S3 bucket name for Terraform remote state."
}

output "tflock_table" {
  value       = aws_dynamodb_table.tflock.name
  description = "DynamoDB table name for Terraform state locking."
}

output "region" {
  value = var.region
}
