output "us_region" {
  description = "US region infrastructure outputs."
  value = {
    vpc_id             = module.us_vpc.vpc_id
    vpc_arn            = module.us_vpc.vpc_arn
    public_subnet_ids  = module.us_vpc.public_subnet_ids
    private_subnet_ids = module.us_vpc.private_subnet_ids
    public_sg_id       = module.us_security_groups.public_sg_id
    private_sg_id      = module.us_security_groups.private_sg_id
    public_instance = {
      instance_id = module.us_public_instance.instance_id
      public_ip   = module.us_public_instance.public_ip
      private_ip  = module.us_public_instance.private_ip
    }
    private_instance = {
      instance_id = module.us_private_instance.instance_id
      private_ip  = module.us_private_instance.private_ip
    }
  }
}

output "eu_region" {
  description = "EU region infrastructure outputs."
  value = {
    vpc_id             = module.eu_vpc.vpc_id
    vpc_arn            = module.eu_vpc.vpc_arn
    public_subnet_ids  = module.eu_vpc.public_subnet_ids
    private_subnet_ids = module.eu_vpc.private_subnet_ids
    public_sg_id       = module.eu_security_groups.public_sg_id
    private_sg_id      = module.eu_security_groups.private_sg_id
    public_instance = {
      instance_id = module.eu_public_instance.instance_id
      public_ip   = module.eu_public_instance.public_ip
      private_ip  = module.eu_public_instance.private_ip
    }
  }
}

output "asia_region" {
  description = "Asia region infrastructure outputs."
  value = {
    vpc_id             = module.asia_vpc.vpc_id
    vpc_arn            = module.asia_vpc.vpc_arn
    public_subnet_ids  = module.asia_vpc.public_subnet_ids
    private_subnet_ids = module.asia_vpc.private_subnet_ids
    public_sg_id       = module.asia_security_groups.public_sg_id
    private_sg_id      = module.asia_security_groups.private_sg_id
    public_instance = {
      instance_id = module.asia_public_instance.instance_id
      public_ip   = module.asia_public_instance.public_ip
      private_ip  = module.asia_public_instance.private_ip
    }
  }
}

output "cloudwan" {
  description = "Cloud WAN outputs when enabled; null for LocalStack-focused runs."
  value = var.enable_cloudwan ? {
    core_network_id   = module.cloudwan[0].core_network_id
    core_network_arn  = module.cloudwan[0].core_network_arn
    global_network_id = module.cloudwan[0].global_network_id
    us_attachment_id  = module.cloudwan[0].us_attachment_id
  } : null
}
