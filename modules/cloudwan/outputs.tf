output "core_network_id" {
  description = "ID of the core network"
  value       = module.cloudwan.core_network.id
}

output "core_network_arn" {
  description = "ARN of the core network"
  value       = module.cloudwan.core_network.arn
}

output "global_network_id" {
  description = "ID of the global network"
  value       = module.cloudwan.global_network.id
}

output "us_attachment_id" {
  description = "ID of US VPC attachment"
  value       = aws_networkmanager_vpc_attachment.us_vpc.id
}
