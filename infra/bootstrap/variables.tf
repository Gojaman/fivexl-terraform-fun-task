variable "project" {
  description = "Project name prefix."
  type        = string
  default     = "fivexl-fun-task"
}

variable "env" {
  description = "Environment name (dev/prod)."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}
