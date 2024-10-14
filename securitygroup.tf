## create network security group

resource "aws_security_group" "sg-k8s" {
  name   = "k8s-sg-all"
  vpc_id = aws_vpc.vpc-k8s.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
