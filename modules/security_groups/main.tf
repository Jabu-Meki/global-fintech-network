resource "aws_security_group" "public" {
  name        = "${var.name_prefix}-public-sg"
  description = "Public Security - allows internet traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-public-sg"
  }
}

# SSH from anywhere (for public instances)
resource "aws_vpc_security_group_ingress_rule" "public_ssh" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# HTTP from anywhere
resource "aws_vpc_security_group_ingress_rule" "public_http" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Private Security Group (restricted)

resource "aws_security_group" "private" {
  name        = "${var.name_prefix}-private-sg"
  description = "Private security group - restricted access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-private-sg"
  }
}

# SSH from public SG
resource "aws_vpc_security_group_ingress_rule" "private_ssh" {
  security_group_id            = aws_security_group.private.id
  referenced_security_group_id = aws_security_group.public.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

# Outbound rules
resource "aws_vpc_security_group_egress_rule" "private_outbound" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
