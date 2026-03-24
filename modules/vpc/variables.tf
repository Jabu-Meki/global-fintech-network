variable "region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "name_prefix" {
  description = "A prefix for naming resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IP Range the VPC should use"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "IP ranges for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "IP ranges for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs where resources should be deployed"
  type        = list(string)
}