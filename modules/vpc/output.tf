output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_subnet_map" {
  value = aws_subnet.public_subnet[*].id
}