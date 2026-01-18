output "vpc_id" {
  description = "id of the main vpc"
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "main vpc cidr block"
  value = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ids of public subnets"
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_id" {
  description = "ids of private subnets"
  value = aws_subnet.private_subnets[*].id
}

output "nat_eip" {
  description = "elastic ip of the nat"
  value = aws_eip.nat_eip[*].public_ip
}