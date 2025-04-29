resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge({
    Name = "${var.name}-vpc"
  }, var.tags)
}

resource "aws_internet_gateway" "this" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = "${var.name}-igw"
  }, var.tags)
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index % length(var.availability_zones)]
  map_public_ip_on_launch = true

  tags = merge({
    Name = "${var.name}-public-${count.index + 1}"
  }, var.tags)
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = merge({
    Name = "${var.name}-private-${count.index + 1}"
  }, var.tags)
}

# Elastic IPs for NAT Gateways (one per AZ if single_nat_gateway = false)
resource "aws_eip" "nat" {
  count      = var.create_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnets)) : 0
  domain     = "vpc"

  tags = merge({
    Name = "${var.name}-nat-eip-${count.index + 1}"
  }, var.tags)
}

# NAT Gateways
resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnets)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id

  tags = merge({
    Name = "${var.name}-nat-${count.index + 1}"
  }, var.tags)

  depends_on = [aws_internet_gateway.this]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.create_igw ? aws_internet_gateway.this[0].id : null
  }

  tags = merge({
    Name = "${var.name}-public-rt"
  }, var.tags)
}

# Private Route Table
resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.create_nat_gateway ? (var.single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id) : null
  }

  tags = merge({
    Name = "${var.name}-private-rt-${count.index + 1}"
  }, var.tags)
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
