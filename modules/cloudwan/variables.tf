variable "us_vpc_arn" {
  description = "ARN of the US VPC"
  type        = string
}

variable "us_private_subnet_arns" {
  description = "ARNs of US private subnets"
  type        = list(string)
}

variable "eu_vpc_arn" {
  description = "ARN of the EU VPC"
  type        = string
}

variable "eu_private_subnet_arns" {
  description = "ARNs of EU private subnets"
  type        = list(string)
}

variable "asia_vpc_arn" {
  description = "ARN of the Asia VPC"
  type        = string
}

variable "asia_private_subnet_arns" {
  description = "ARNs of Asia private subnets"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}