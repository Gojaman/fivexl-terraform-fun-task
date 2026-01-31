variable "name" { type = string }
variable "region" { type = string }

# Turn service on only after we push an image to ECR
variable "enable_service" { type = bool, default = false }

# Image tag (we'll use site hash)
variable "image_tag" { type = string, default = "" }

variable "container_port" { type = number, default = 80 }
variable "cpu" { type = number, default = 256 }
variable "memory" { type = number, default = 512 }
