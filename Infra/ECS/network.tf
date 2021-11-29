resource "aws_vpc" "ECS-VPC" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = "ECSVPC"
    Enviroment = var.env-tag
  }
}

resource "aws_security_group" "lamp-sg" {
    name = "lampsg"
    description = "security group for lamp app in ECS"
  tags = {
    Name = "lampsg"
    Enviroment = var.env-tag
  }
}

resource "aws_subnet" "public" {
  count = var.subnet-count
  cidr_block = cidrsubnet(aws_vpc.ECS-VPC.cidr_block, 4, 0+count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id = aws_vpc.ECS-VPC.id
  tags = {
    Name = "public${count.index+1}"
    Enviroment = var.env-tag
  }
}

resource "aws_subnet" "private" {
  count             = var.subnet-count
  cidr_block        = cidrsubnet(aws_vpc.ECS-VPC.cidr_block, 4, var.subnet-count + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.ECS-VPC.id
  tags = {
    Name = "peivate${count.index+1}"
    Enviroment = var.env-tag
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.ECS-VPC.id
  tags = {
    Name = "Gateway"
    Enviroment = var.env-tag
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.ECS-VPC.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count      = var.subnet-count
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
  tags = {
    Name = "lampIP"
    Enviroment = var.env-tag
  }
}

resource "aws_nat_gateway" "gateway" {
  count         = var.subnet-count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
  tags = {
    Name = "NatGate${count.index+1}"
    Enviroment = var.env-tag
  }
}

resource "aws_route_table" "private" {
  count  = var.subnet-count
  vpc_id = aws_vpc.ECS-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
  tags = {
    Name = "ECSRoute"
    Enviroment = var.env-tag
  }
}

resource "aws_route_table_association" "private" {
  count          = var.subnet-count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_security_group" "lb" {
  name        = "example-alb-security-group"
  vpc_id      = aws_vpc.ECS-VPC.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "lbsg"
    Enviroment = var.env-tag
  }
}