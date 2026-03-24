resource "aws_subnet" "public" {
  for_each                = local.public_subnets_map
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    # Conditional Tagging for Public ALBs (Internet-facing)
    var.eks_cluster_name != null ? {
      "kubernetes.io/role/elb"                        = "1"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    } : {},
    {
      Name = "${var.platform}-${var.environment}-public-subnet-${each.key}"
    }
  )
}

resource "aws_subnet" "private" {
  for_each          = local.private_subnets_map
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    local.tags,
    # Conditional Tagging for Internal ALBs
    var.eks_cluster_name != null ? {
      "kubernetes.io/role/internal-elb"               = "1"
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    } : {},
    {
      Name = "${var.platform}-${var.environment}-private-subnet-${each.key}"
    }
  )
}

resource "aws_subnet" "db" {
  for_each          = local.db_subnets_map
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(
    local.tags,
    {
      Name = "${var.platform}-${var.environment}-db-subnet-${each.key}"
    }
  )
}

resource "aws_db_subnet_group" "this" {
  count = length(local.db_subnets_map) > 0 ? 1 : 0

  name       = "${var.platform}-${var.environment}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.db : s.id]

  tags = merge(
    local.tags,
    {
      Name = "${var.platform}-${var.environment}-db-subnet-group"
    }
  )
}