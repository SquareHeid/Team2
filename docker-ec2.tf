
# Create AWS-EC2 Docker host
resource "aws_instance" "docker-compose" {
  ami                         = var.ami["dc-node"]
  instance_type               = var.instance_type["dc-node"]
  key_name                    = aws_key_pair.k8s_key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.cluster-subnet.id
  vpc_security_group_ids      = [aws_security_group.sg-k8s.id]
  
  tags = {
    Name = "docket_host"
  }
depends_on = [aws_instance.team2jvs] # Wait for the jump host to be created

# Connections done using SSH
  connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key)
      host        = self.public_ip
    }
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname docker_host",
    ]
  }

}