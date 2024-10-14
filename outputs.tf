output "team2jvs" {
description = "Jump host or Ansible node Details"
  value       = {
public_ip = aws_instance.team2jvs.public_ip
private_ip = aws_instance.team2jvs.private_ip
hostname = aws_instance.team2jvs.tags["Name"]

  }
}

output "master_ip" {
  value = {
    
  public_ip =  aws_instance.master.public_ip
  private_ip = aws_instance.master.private_ip
  hostname = aws_instance.master.tags["Name"]
  }
}

output "worker_ips" {
  value = [for i in aws_instance.wnode : {
    public_ip = i.public_ip
    private_ip = i.private_ip
    hostname = i.tags["Name"]
}
]
}

output "docker-compose" {
  value = {
    public_ip = aws_instance.docker-compose.public_ip
    private_ip = aws_instance.docker-compose.private_ip
    hostname = aws_instance.docker-compose.tags["Name"]
  }
}
