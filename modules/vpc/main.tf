################################################################################
# VPC MODULE
# Date: April 14th, 2024. 
# VPC creation with 2 public and private subnets with NAT attached to private
# route and igw attached to main public route. No NACL and SGs configured. 
#
# usecase for pub-pri-subnets-deployment-with-as-and-alb
################################################################################



# get availability zones for current region
data "aws_availability_zones" "availablezones" {}

locals {
  name = "${var.vpc_name}-${basename(path.cwd)}"
  
  azs = slice(data.aws_availability_zones.availablezones.names, 0, length(data.aws_availability_zones.availablezones.names))

  private_subnets_cidr_list = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  public_subnets_cidr_list = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 4)]
  
  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# VPC Module
################################################################################

resource "aws_vpc" "vpc_terraform_project" {
    
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true
    
    tags = {
      name = local.name
    }
}


########################################################
# Subnets (Public and Private)
########################################################

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.vpc_terraform_project.id
    cidr_block = local.public_subnets_cidr_list[0]
    availability_zone = local.azs[0]
    # map_customer_owned_ip_on_launch = true

    tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.vpc_terraform_project.id
    cidr_block = local.public_subnets_cidr_list[1]
    availability_zone = local.azs[1]
    # map_customer_owned_ip_on_launch = true

    tags = {
    Name = "PublicSubnet2"
  }
}


resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.vpc_terraform_project.id
    cidr_block = local.private_subnets_cidr_list[0]
    availability_zone = local.azs[0]

    tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.vpc_terraform_project.id
    cidr_block = local.private_subnets_cidr_list[1]
    availability_zone = local.azs[1]

    tags = {
    Name = "PrivateSubnet2"
  }
}

########################################################
# Route tables, NAT, IGW
########################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_terraform_project.id
}

resource "aws_route_table" "RT-public" {
  vpc_id = aws_vpc.vpc_terraform_project.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-RT"
  }
}

resource "aws_eip" "nat_eip-1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip-2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway-1" {
  allocation_id = aws_eip.nat_eip-1.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "NAT-gateway-1"
  }
}

resource "aws_nat_gateway" "nat_gateway-2" {
  allocation_id = aws_eip.nat_eip-2.id
  subnet_id     = aws_subnet.public_subnet_2.id

  tags = {
    Name = "NAT-gateway-2"
  }
}

resource "aws_route_table" "RT-private-1" {
  vpc_id = aws_vpc.vpc_terraform_project.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway-1.id
  }

  tags = {
    Name = "Private-RT-1"
  }
}

resource "aws_route_table" "RT-private-2" {
  vpc_id = aws_vpc.vpc_terraform_project.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway-2.id
  }

  tags = {
    Name = "Private-RT-2"
  }
}

########################################################
# RT association
########################################################

resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.RT-public.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.RT-public.id
}

resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.RT-private-1.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.RT-private-2.id
}

