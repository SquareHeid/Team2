# Create AWS-EC2 Jump host.
resource "aws_instance" "team2jvs" {
  ami                         = var.ami["jump-node"]
  instance_type               = var.instance_type["jump-node"]
  key_name                    = aws_key_pair.k8s_key_pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.cluster-subnet.id
  vpc_security_group_ids      = [aws_security_group.sg-k8s.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }
  tags = {
    Name = "ansible-master"
  }

 # Connections done using SSH
  connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key)
      host        = self.public_ip
    }
  # Copy the jump installation script and yaml
  provisioner "file" {
    source      = "scripts/jump-setup.sh"
    destination = "/home/ubuntu/jump-setup.sh"
  }
  # Setting permission to jump-setup which will update and install ansible
  provisioner "remote-exec" {
    inline = [
    # Set up SSH keys
    "echo '${file(var.private_key)}' > /home/ubuntu/.ssh/id_rsa",
    "echo '${file(var.public_key)}' > /home/ubuntu/.ssh/id_rsa.pub",
    "cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys",
    # Make the jump setup script executable and run it
    "chmod +x /home/ubuntu/jump-setup.sh",
    "/home/ubuntu/jump-setup.sh",
    # Set permissions and ownership in one step
    "chmod 700 /home/ubuntu/.ssh && chmod 600 /home/ubuntu/.ssh/id_rsa /home/ubuntu/.ssh/authorized_keys && chmod 644 /home/ubuntu/.ssh/id_rsa.pub",
    "chown -R ubuntu:ubuntu /home/ubuntu/.ssh",
    ]
  }
provisioner "file" {
    source      = "playbook/"
    destination = "/home/ubuntu/playbook/"
  }
} #end of jump node block


#Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
 content = templatefile("${path.module}/inventory.tmpl",
    {
      ansible_master_ip = aws_instance.team2jvs.private_ip
      docker_host_ip    = aws_instance.docker-compose.private_ip
      k8s_master_ip     = aws_instance.master.private_ip
      k8s_worker_ips    = aws_instance.wnode[*].private_ip
    }
  )#end of content block
  filename = "${path.module}/inventory.ini" 
}

# Create a null resource to copy the SSH public key to all instances after they are created
resource "null_resource" "post-task_runner" {
  # Create a dependency on all EC2 instances
 depends_on = [
    aws_instance.team2jvs,
    aws_instance.docker-compose,
    aws_instance.master,
    aws_instance.wnode
  ]
  
 connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key)
    host        = aws_instance.team2jvs.public_ip
  }
 
 provisioner "file" {
    source      = "${local_file.ansible_inventory.filename}"
    destination = "/home/ubuntu/inventory.ini"
  }

 provisioner "remote-exec" {
    inline = [
    # Copy and set permissions on the inventory file
    "sudo cp /home/ubuntu/inventory.ini /etc/ansible/inventory.ini",
    "sudo chmod 644 /etc/ansible/inventory.ini",
    # Set permissions on the YAML playbook files
    "echo Setting permission on copied yaml files in /home/ubuntu/playbook folder",
    "sudo cp /home/ubuntu/playbook/*.yaml /etc/ansible/",
    "sudo chmod 644 /etc/ansible/*.yaml",
    "echo Playbooks copied successfully.",
    
    # Run playbooks
    # Step 1: Run system playbooks
    "echo 'Running update-hostfile.yaml... on Ansible jump host'",
    "ansible-playbook -i /etc/ansible/inventory.ini /etc/ansible/update-hostfile.yaml || { echo 'update-hostfile.yaml failed!'; exit 1; }",
      
    "echo 'Running ansible_authorized_key.yaml... to copy the pub key to all hosts in inventory.ini file'",
    # "ansible-playbook -i /etc/ansible/inventory.ini /etc/ansible/ansible_authorized_key.yaml || { echo 'ansible_authorized_key.yaml failed!'; exit 1; }",
    "ansible-playbook -i /etc/ansible/inventory.ini --private-key=/home/ubuntu/.ssh/id_rsa /etc/ansible/ansible_authorized_key.yaml || { echo 'ansible_authorized_key.yaml failed!'; exit 1; }",

    "echo 'Running disablesshstrict.yaml... it will disable the fingerprint warnings'",
    "ansible-playbook -i /etc/ansible/inventory.ini /etc/ansible/disablesshstrict.yaml || { echo 'disablesshstrict.yaml failed!'; exit 1; }",

    # Step 2: Run Docker installation playbook on docker host
    "echo 'Running Install-docker.yaml...'",
    "ansible-playbook -i /etc/ansible/inventory.ini /etc/ansible/Install-docker.yaml || { echo 'Install-docker.yaml failed!'; exit 1; }",

    # Step 3: Run Kubernetes playbooks in order
    "echo 'Running T1-Kube-dependencies.yaml...'",
    "ansible-playbook -i /etc/ansible/inventory.ini /etc/ansible/T1-Kube-dependencies.yaml || { echo 'T1-Kube-dependencies.yaml failed!'; exit 1; }",

    "echo 'Running T2-kube_master.yaml...'",
    "ansible-playbook -i /etc/ansible/inventory.ini /etc/ansible/T2-kube_master.yaml || { echo 'T2-kube_master.yaml failed!'; exit 1; }",

      "echo 'Running T3-kube_worker.yaml...'",
      "ansible-playbook -i /etc/ansible/inventory.ini /etc/ansible/T3-kube_worker.yaml || { echo 'T3-kube_worker.yaml failed!'; exit 1; }"
                
    ]#end of inline blocl
  }#end of provisioner block
}#end of null resource block