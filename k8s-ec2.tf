#Create Kubernetes Master node
resource "aws_instance" "master" {
  ami                         = var.ami["master"]
  instance_type               = var.instance_type["master"]
  key_name                    = aws_key_pair.k8s_key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.cluster-subnet.id
  vpc_security_group_ids      = [aws_security_group.sg-k8s.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 14
  }
  timeouts {
    create = "10m"
  }

  tags = {
    Name = "master-${var.k8s_name}"
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
    "sudo hostnamectl set-hostname k8s_master",
    ]
  }

}#end of Master node resource block

# Create Worker nodes for cluster
resource "aws_instance" "wnode" {
  count                       = var.node_count
  ami                         = var.ami["worker-node"]
  instance_type               = var.instance_type["worker-node"]
  key_name                    = aws_key_pair.k8s_key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.cluster-subnet.id
  vpc_security_group_ids      = [aws_security_group.sg-k8s.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }
  tags = {
    Name = "worker-node-${count.index + 1}"
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
      "sudo hostnamectl set-hostname k8s-worker-${count.index + 1}",
      "echo '${file(var.public_key)}' > /home/ubuntu/.ssh/id_rsa.pub",
      "cat /home/ubuntu/.ssh/id_rsa.pub", # Debug output
      "cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys",
      "chmod 700 /home/ubuntu/.ssh",
      "chmod 600 /home/ubuntu/authorized_keys",
      "chmod 644 /home/ubuntu/.ssh/id_rsa.pub",
      "chown -R ubuntu:ubuntu /home/ubuntu/.ssh"
    ]
  }

}# End of Worker node resource block
