variable "region" {
  description = "The region where the security groups will be created."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security groups will be created."
  type        = string
}

variable "name_prefix" {
  description = "The prefix for the security group names."
  type        = string
}