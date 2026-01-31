variable "project" {
  type    = string
  default = "fivexl-fun-task"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ec2_site_hash" {
  type    = string
  default = "init"
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ec2_ssh_key_name" {
  type    = string
  default = null
}
