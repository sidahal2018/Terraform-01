# Get list of availability zones
data "aws_availability_zones" "available" {
state = "available"
}

provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block                     = var.vpc_cidr
  enable_dns_support             = var.enable_dns_support 
  enable_dns_hostnames           = var.enable_dns_support
  enable_classiclink             = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink
  
}

# Create public subnets
resource "aws_subnet" "public" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
  vpc_id = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4 , count.index +3)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
tags = {
    Name        =  format("PublicSubnet-%s", count.index)
    Environment = var.environment
  }
}
resource "aws_subnet" "private" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4 , count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name        =  format("PrivateSubnet-%s", count.index)
    Environment = var.environment

  }
}