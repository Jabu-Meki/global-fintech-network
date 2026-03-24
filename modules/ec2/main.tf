# Create the EC2 instance

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip

  tags = {
    Name = var.name
  }
}
