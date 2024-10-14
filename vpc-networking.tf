#Task1 - Create Virtual Private Cloud (VPC)

resource "aws_vpc" "vpc-k8s" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.k8s_name}"
  }
}

# Task2 - create VPC subnet
resource "aws_subnet" "cluster-subnet" {
  vpc_id                  = aws_vpc.vpc-k8s.id
  cidr_block              = var.cidr_subnet
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.k8s_name}"
  }
}

# Task3 - Create Ineternet gateway
resource "aws_internet_gateway" "igw_k8s" {
  vpc_id = aws_vpc.vpc-k8s.id
  tags = {
    Name = "igw-${var.k8s_name}"
  }
}

# Task4 - Create route table

resource "aws_route_table" "rtb_k8s" {
  vpc_id = aws_vpc.vpc-k8s.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_k8s.id
  }
  tags = {
    Name = "rt-${var.k8s_name}"
  }
}

# Task5 create Route Table association for public VPC subnet

resource "aws_route_table_association" "rta_k8s_subnets" {
  subnet_id      = aws_subnet.cluster-subnet.id
  route_table_id = aws_route_table.rtb_k8s.id

}
