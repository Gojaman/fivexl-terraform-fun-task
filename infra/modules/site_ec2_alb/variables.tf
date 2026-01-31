variable "name" {
  type = string
}

variable "region" {
  type = string
}

# Any change here forces instance rotation (auto redeploy)
variable "site_hash" {
  type = string
}

# Instance settings
variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_key_name" {
  type    = string
  default = null
}
