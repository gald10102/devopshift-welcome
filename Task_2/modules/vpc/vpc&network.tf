provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-east-1"
}

variable "name" {
  type = string
  default = "Gal3"
}

variable "vpc_cidr_range" {
  type = string
  #user should enter cider range 
}

variable "subnet_count"{
  type = number
  #user should enter number of subnets
}

resource "aws_vpc" "create_vpc" {
    cidr_block = var.vpc_cidr_range
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.name}-VPC"
    }
}

resource "aws_route_table" "create_public_routing_table" {
  vpc_id = aws_vpc.create_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.creating_gateway.id
  }
  tags = {
    Name = "${var.name}-public_routingTable"
  }
}

module "create_public_subnet_1" {
  source = "../subnets"
  subnet_number = 1
  vpc_id = aws_vpc.create_vpc.id
  cider_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  routing_table_id = aws_route_table.create_public_routing_table.id
  depends_on = [aws_vpc.create_vpc]
}

module "create_public_subnet_2" {
  source = "../subnets"
  subnet_number = 2
  vpc_id = aws_vpc.create_vpc.id
  cider_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  routing_table_id = aws_route_table.create_public_routing_table.id

  depends_on = [aws_vpc.create_vpc]
}


resource "aws_subnet" "create_private_subnet" {
  vpc_id = aws_vpc.create_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a" 
  tags = {
    Name = "${var.name}-private_subnet"
  }
}


resource "aws_internet_gateway" "creating_gateway" {
  vpc_id = aws_vpc.create_vpc.id
  tags = {
    Name = "InternetGateway"
  }
}





resource "aws_route_table" "create_private_routing_table" {
  vpc_id = aws_vpc.create_vpc.id
  
  tags = {
    Name = "${var.name}-private_routingTable"
  }
}

resource "aws_route_table_association" "route_private_publassosiation" {
  subnet_id = aws_subnet.create_private_subnet.id
  route_table_id = aws_route_table.create_private_routing_table.id
}

resource "aws_security_group" "allowing_ssh_http" {
  vpc_id = aws_vpc.create_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-sg"
  }
}

output "get_subnet_id" {
  value = module.create_public_subnet_1.subnet_id
}

output "get_sg_id" {
  value = aws_security_group.allowing_ssh_http.id
}

output "subnets_ids" {
  value = [module.create_public_subnet_1.subnet_id,module.create_public_subnet_2.subnet_id]
}

output "get_vpc_id" {
  value = aws_vpc.create_vpc.id
}