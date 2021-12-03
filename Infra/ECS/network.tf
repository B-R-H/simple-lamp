resource "aws_vpc" "default_vpc" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = "ECSVPC"
    Enviroment = var.env-tag
  }
}

resource "aws_subnet" "default_subnets" {
  vpc_id = aws_vpc.default_vpc.id
  count = var.subnet-count
  cidr_block = cidrsubnet(aws_vpc.default_vpc.cidr_block, 7, 0+count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index%length(data.aws_availability_zones.available_zones.names)]
  tags = {
    Name = "public${count.index +1}"
    Enviroment = var.env-tag
  }
}

resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.default_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
  tags = {
    Name = "lbToBack"
    Enviroment = var.env-tag
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.default_vpc.id
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
  tags = {
    Name = "lb to internet"
    Enviroment = var.env-tag
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.default_vpc.id
  tags = {
    Name = "Gateway"
    Enviroment = var.env-tag
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default_vpc.main_route_table_id
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