variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "name" {
  description = "Name of the instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the instance. Defaults to a LocalStack-safe placeholder."
  type        = string
  default     = "ami-12345678"
}

variable "subnet_id" {
  description = "Subnet to launch the instance in"
  type        = string
}

variable "security_group_ids" {
  description = "Security group to attach to the instance"
  type        = list(string)
}

variable "associate_public_ip" {
  description = "Should the instance get a public IP"
  type        = bool
  default     = false
}
