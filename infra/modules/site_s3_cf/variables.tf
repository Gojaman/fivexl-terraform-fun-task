variable "name" {
  description = "Name prefix for resources."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "site_dir" {
  description = "Path to local site directory."
  type        = string
}
