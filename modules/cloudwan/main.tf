module "cloudwan" {
  source  = "aws-ia/cloudwan/aws"
  version = "~> 3.4.0"

  providers = {
    aws = aws
  }

  global_network = {
    description = "Global network for FinTech Unicorn"
    tags = {
      Name = "fintech-global-network"
    }
  }

  core_network = {
    description     = "Core Network"
    policy_document = data.aws_networkmanager_core_network_policy_document.policy.json
    tags = {
      Name = "fintech-core-network"
    }
  }

  tags = {
    Environment = "production"
    Project     = "fintech-global"
  }
}
