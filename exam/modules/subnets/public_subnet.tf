variable "cider_block" {
  type = string
}

variable "subnet_number" {
  type = number
}

variable "availability_zone" {
    type = string
}

variable "vpc_id" {
  type = string
}

variable "routing_table_id" {
  type = string
}

resource "aws_subnet" "public_subnet" {
  vpc_id                 = var.vpc_id
  cidr_block             = var.cider_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "public-subnet-${var.subnet_number}"
  }
}

resource "aws_route_table_association" "route_public_assosiation" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = var.routing_table_id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}
