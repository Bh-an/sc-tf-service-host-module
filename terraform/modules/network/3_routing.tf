# -----------------------------------------------------------------------------
# Public Routing
# -----------------------------------------------------------------------------

resource "aws_route_table" "public" {
  count  = local.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.tags,
    {
      Name = "${var.platform}-${var.environment}-public-rt"
    }
  )
}

# Standalone Route: Internet Access
resource "aws_route" "public_internet" {
  count = local.create_public_subnets ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each  = aws_subnet.public
  subnet_id = each.value.id

  route_table_id = aws_route_table.public[0].id
}

# -----------------------------------------------------------------------------
# Private Routing (Application)
# -----------------------------------------------------------------------------

resource "aws_route_table" "private" {
  for_each = local.private_subnets_map
  vpc_id   = aws_vpc.this.id


  tags = merge(
    local.tags,
    {
      Name = "${var.platform}-${var.environment}-private-rt-${each.key}"
    }
  )
}

# Standalone Route: NAT Gateway Access
resource "aws_route" "private_nat" {
  for_each = length(aws_nat_gateway.this) > 0 ? local.private_subnets_map : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this[var.availability_zones[0]].id : aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

# -----------------------------------------------------------------------------
# DB Routing (Isolated)
# -----------------------------------------------------------------------------

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.tags,
    {
      Name = "${var.platform}-${var.environment}-db-rt"
    }
  )
}

resource "aws_route_table_association" "db" {
  for_each       = aws_subnet.db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}