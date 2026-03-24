# US REGION

module "us_vpc" {
  source = "../../modules/vpc"

  region      = "us-east-1"
  name_prefix = "us"
  vpc_cidr    = "10.0.0.0/16"

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
}

module "us_security_groups" {
  source = "../../modules/security_groups"

  region      = "us-east-1"
  name_prefix = "us"
  vpc_id      = module.us_vpc.vpc_id
}

module "us_public_instance" {
  source = "../../modules/ec2"

  region              = "us-east-1"
  name                = "us-public-instance"
  subnet_id           = module.us_vpc.public_subnet_ids[0] # First public subnet
  security_group_ids  = [module.us_security_groups.public_sg_id]
  associate_public_ip = true
}

module "us_private_instance" {
  source = "../../modules/ec2"

  region              = "us-east-1"
  name                = "us-private-instance"
  subnet_id           = module.us_vpc.private_subnet_ids[0] # First private subnet
  security_group_ids  = [module.us_security_groups.private_sg_id]
  associate_public_ip = false
}

# EU REGION

module "eu_vpc" {
  source = "../../modules/vpc"

  region      = "eu-west-1"
  name_prefix = "eu"
  vpc_cidr    = "10.1.0.0/16"

  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
  availability_zones   = ["eu-west-1a", "eu-west-1b"]

  providers = {
    aws = aws.eu
  }
}

module "eu_security_groups" {
  source = "../../modules/security_groups"

  region      = "eu-west-1"
  name_prefix = "eu"
  vpc_id      = module.eu_vpc.vpc_id

  providers = {
    aws = aws.eu
  }
}

module "eu_public_instance" {
  source = "../../modules/ec2"

  region              = "eu-west-1"
  name                = "eu-public-instance"
  subnet_id           = module.eu_vpc.public_subnet_ids[0] # First public subnet
  security_group_ids  = [module.eu_security_groups.public_sg_id]
  associate_public_ip = true

  providers = {
    aws = aws.eu
  }
}

# ASIA REGION

module "asia_vpc" {
  source = "../../modules/vpc"

  region      = "ap-southeast-1"
  name_prefix = "asia"
  vpc_cidr    = "10.2.0.0/16"

  public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]
  availability_zones   = ["ap-southeast-1a", "ap-southeast-1b"]

  providers = {
    aws = aws.asia
  }
}

module "asia_security_groups" {
  source = "../../modules/security_groups"

  region      = "ap-southeast-1"
  name_prefix = "asia"
  vpc_id      = module.asia_vpc.vpc_id

  providers = {
    aws = aws.asia
  }
}

module "asia_public_instance" {
  source = "../../modules/ec2"

  region              = "ap-southeast-1"
  name                = "asia-public-instance"
  subnet_id           = module.asia_vpc.public_subnet_ids[0]
  security_group_ids  = [module.asia_security_groups.public_sg_id]
  associate_public_ip = true

  providers = {
    aws = aws.asia
  }
}

module "cloudwan" {
  count  = var.enable_cloudwan ? 1 : 0
  source = "../../modules/cloudwan"

  us_vpc_arn             = module.us_vpc.vpc_arn
  us_private_subnet_arns = module.us_vpc.private_subnet_arns

  eu_vpc_arn             = module.eu_vpc.vpc_arn
  eu_private_subnet_arns = module.eu_vpc.private_subnet_arns

  asia_vpc_arn             = module.asia_vpc.vpc_arn
  asia_private_subnet_arns = module.asia_vpc.private_subnet_arns

  environment = "prod"

  providers = {
    aws      = aws
    aws.eu   = aws.eu
    aws.asia = aws.asia
  }
}
