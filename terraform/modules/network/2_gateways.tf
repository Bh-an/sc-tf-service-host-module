resource "aws_internet_gateway" "this" {
  count = local.create_public_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.tags,
    {
      Name = "${var.platform}-${var.environment}-igw"
    }
  )
}

resource "aws_eip" "nat" {
  for_each = local.nat_gateway_target_map
  domain   = "vpc"

  tags = merge(
    local.tags,
    {
      Name = "${var.platform}-${var.environment}-nat-eip-${each.key}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  for_each      = local.nat_gateway_target_map
  allocation_id = aws_eip.nat[each.key].id

  subnet_id = aws_subnet.public[each.key].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    local.tags,
    {
      Name = "${var.platform}-${var.environment}-nat-gw-${each.key}"
    }
  )
}