
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
  }
    tags = {
    Name        = format("Public-RT-%s", var.environment)
    Environment = var.environment
  }
}
resource "aws_route_table_association" "public" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}
# private route table for first private subnet
resource "aws_route_table" "private" {
  count = var.preferred_number_of_private_subnets_2 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_2
  vpc_id = aws_vpc.main.id
  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
    tags = {
    Name        =  format("Private-RT, %s!",var.environment)
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private" {
  count = var.preferred_number_of_private_subnets_2 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
# create route tables for second private subnet

resource "aws_route_table" "private_2" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  vpc_id = aws_vpc.main.id
    tags = {
    Name        =  format("private_2-RT, %s!",var.environment)
    Environment = var.environment
  }
}

resource "aws_route" "private_2" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  route_table_id         = aws_route_table.private_2[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_2" {
  count = var.preferred_number_of_private_subnets_1 == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets_1
  subnet_id      = aws_subnet.private_2[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}