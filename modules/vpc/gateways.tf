# igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "kindred-${var.infra_env}-vpc"
    Project     = "kindred.dev"
    Environment = var.infra_env
    VPC         = aws_vpc.vpc.id
    ManagedBy   = "terraform"
  }
}

#ngw
resource "aws_eip" "nat" {
  vpc = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "kindred-${var.infra_env}-vpc"
    Project     = "kindred.dev"
    Environment = var.infra_env
    VPC         = aws_vpc.vpc.id
    ManagedBy   = "terraform"
    Role        = "private"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id

  # Whichever the first public subnet happens to be
  # (because NGW needs to be on a public subnet with an IGW)
  # keys(): https://www.terraform.io/docs/configuration/functions/keys.html
  # element(): https://www.terraform.io/docs/configuration/functions/element.html

  subnet_id = aws_subnet.public[element(keys(aws_subnet.public), 0)].id

  tags = {
    Name        = "kindred-${var.infra_env}-ngw"
    Project     = "kindred.dev"
    Environment = var.infra_env
    VPC         = aws_vpc.vpc.id
    ManagedBy   = "terraform"
    Role        = "private"
  }
}

# Route Table and Routes and Associations

# Public Route Table (Subnets with IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "kindred-${var.infra_env}-public-rt"
    Project     = "kindred.dev"
    Environment = var.infra_env
    VPC         = aws_vpc.vpc.id
    ManagedBy   = "terraform"
    Role        = "public"
  }
}

# Private Route Tables (Subnets with NGW)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "kindred-${var.infra_env}-private-rt"
    Project     = "kindred.dev"
    Environment = var.infra_env
    VPC         = aws_vpc.vpc.id
    ManagedBy   = "terraform"
    Role        = "private"
  }
}

# public route
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# private route
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

# Public Route to Public Route Table for Public Subnets
resource "aws_route_table_association" "public" {
  for_each  = aws_subnet.public
  subnet_id = aws_subnet.public[each.key].id

  route_table_id = aws_route_table.public.id
}

# Private Route to Private Route Table for Private Subnets
resource "aws_route_table_association" "private" {
  for_each  = aws_subnet.private
  subnet_id = aws_subnet.private[each.key].id

  route_table_id = aws_route_table.private.id
}