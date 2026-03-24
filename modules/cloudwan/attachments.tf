resource "aws_networkmanager_vpc_attachment" "us_vpc" {
  core_network_id = module.cloudwan.core_network.id
  vpc_arn         = var.us_vpc_arn
  subnet_arns     = var.us_private_subnet_arns

  tags = {
    segment = "prod"
    Name    = "us-vpc-attachment"
  }

  options {
    appliance_mode_support = false # remove this line if you want to use appliances in this VPC
  }
}

resource "aws_networkmanager_vpc_attachment" "eu_vpc" {
  provider = aws.eu

  core_network_id = module.cloudwan.core_network.id
  vpc_arn         = var.eu_vpc_arn
  subnet_arns     = var.eu_private_subnet_arns

  tags = {
    segment = "prod"
    Name    = "eu-vpc-attachment"
  }
}

resource "aws_networkmanager_vpc_attachment" "ap_vpc" {
  provider = aws.asia

  core_network_id = module.cloudwan.core_network.id
  vpc_arn         = var.asia_vpc_arn
  subnet_arns     = var.asia_private_subnet_arns

  tags = {
    segment = "dev"
    Name    = "ap-vpc-attachment"
  }
}
