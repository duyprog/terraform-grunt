data "aws_availability_zones" "az" {

}
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.env}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.public_subnets)
  # cidr_block        = cidrsubnet(aws_vpc.production.cidr_block, 8, count.index + 1)
  cidr_block = var.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Public subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "${var.env}-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "${var.env} Public Route Table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = 2
  route_table_id = element(aws_route_table.public_route_table.*.id, count.index)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
}