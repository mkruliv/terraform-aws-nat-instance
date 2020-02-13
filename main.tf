data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^amzn2-ami-hvm.*-gp2"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "nat_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.4.0"

  name        = "nat-instance-${var.env_name}"
  description = "Security group for nat-instance"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "acceess from vpc"
      cidr_blocks = var.vpc_cidr #access form vpc
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "acceess from bastion"
      cidr_blocks = var.bastion_subnet_cidr #access form bastion
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

resource "aws_network_interface" "nat_eni" {
  subnet_id         = var.vpc_public_subnet
  source_dest_check = false
  security_groups   = [module.nat_sg.this_security_group_id]
  tags = {
    Name        = "ENI-NAT-${var.env_name}"
    Environment = var.env_name
  }
}

resource "aws_eip" "nat_eip" {
  vpc               = true
  network_interface = aws_network_interface.nat_eni.id
}

module "nat_ec2" {
  source            = "terraform-aws-modules/ec2-instance/aws"
  version           = "~> 2.0"
  instance_count    = 1
  key_name          = var.key_pair
  source_dest_check = false
  user_data         = file("${path.module}/files/user_data")
  name              = "nat-instance-${var.env_name}"
  ami               = data.aws_ami.amazon-linux-2.id
  instance_type     = var.nat_instance_type
  subnet_id         = var.vpc_public_subnet
  network_interface = [
    {
      device_index          = 0
      network_interface_id  = aws_network_interface.nat_eni.id
      delete_on_termination = false
    }
  ]
  root_block_device = [
    {
      volume_type = var.nat_ebs_root_type
      volume_size = var.nat_ebs_root_size
    },
  ]
  tags = {
    Environment = var.env_name
  }
}

resource "aws_route" "this-route-private-a" {
  route_table_id         = var.vpc_private_routes[0]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat_eni.id
}

resource "aws_route" "this-route-private-b" {
  route_table_id         = var.vpc_private_routes[1]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat_eni.id
}

resource "aws_route_table_association" "nat-a" {
  subnet_id      = var.vpc_private_subnets[0]
  route_table_id = var.vpc_private_routes[0]
}

resource "aws_route_table_association" "nat-b" {
  subnet_id      = var.vpc_private_subnets[1]
  route_table_id = var.vpc_private_routes[1]
}