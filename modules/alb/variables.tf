
variable "vpc_id" {
  description = "The VPC ID from module vpc"
  type        = string
}

variable "public_subnet_id1" {
  description = "ID of the first public subnet"
  type = string
}

variable "public_subnet_id2" {
  description = "ID of the first public subnet"
  type = string
}

variable "alb_tg" {
  type = string
}