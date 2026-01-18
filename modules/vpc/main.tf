resource "aws_vpc" "main" {
 cidr_block = var.vpc_cidr
 enable_dns_hostnames = true
 enable_dns_support = true 
 tags = {
    Name = "Inpage-Vpc"
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-public-subnet-${count.index+1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.project}-private-subnet-${count.index+1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat_eip" {
  count = length(var.availability_zones)
  domain = "vpc"
  depends_on = [ aws_internet_gateway.main ]
}

resource "aws_nat_gateway" "nat" {
  count = length(var.availability_zones) 
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.public_subnets[count.index].id
  depends_on = [ aws_eip.nat_eip ]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_subnet_assc" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_nat" {
  count = length(var.availability_zones)
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.private_rt.id
  nat_gateway_id = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_subnet_assc" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}