# create ssh keypair for the instances
# resource "tls_private_key" "k8s_privkey" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
#   provisioner "local-exec" { # Create a "pubkey.pem" to your computer!!
#     command = "echo '${self.public_key_pem}' > ./pubkey.pem"
#   }
# }
resource "aws_key_pair" "k8s_key_pair" {
  key_name   = var.key_name
  public_key = var.publick_key
  #public_key = tls_private_key.k8s_privkey.public_key_openssh
  #provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
  #  command = "echo '${tls_private_key.k8s_privkey.private_key_pem}' > ./myKey.pem"
  }

# # save to local computer
# resource "local_file" "mykeys" {
#   content = tls_private_key.k8s_privkey.private_key_pem
#   filename = "mypkey"
# }

# Create Controlplane (Master)
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
provisioner "local-exec" {
    command = "echo 'master ${self.public_ip}' >> ./files/hosts"
  }
}


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
    Name = "worker-node-${count.index}"
  }
provisioner "local-exec" {
    command = "echo 'worker-${count.index} ${self.public_ip}' >> ./files/hosts"
  }
}

# Define the host as an Ansible resource for master
resource "ansible_host" "master" {
  depends_on = [aws_instance.master]
  name       = "controlplane"
  groups     = ["master"]
  variables = {
    ansible_user                 = "ubuntu"
    ansible_host                 = aws_instance.master.public_ip
    ansible_ssh_private_key_file = "./id_rsa"
    node_hostname                = "master"
  }
}

# Define the host as an Ansible resource for workers
resource "ansible_host" "worker" {
  depends_on = [aws_instance.wnode]
  count      = 2
  name       = "worker-node-${count.index}"
  groups     = ["workers"]
  variables = {
    ansible_user                 = "ubuntu"
    ansible_host                 = aws_instance.wnode[count.index].public_ip
    ansible_ssh_private_key_file = "./id_rsa"
    node_hostname                = "worker-node-${count.index}"
  }
}

output "master_ip" {
  value = aws_instance.master.public_ip
}

output "worker-node_ip" {
  value = [for i in aws_instance.wnode : i.public_ip]
}
