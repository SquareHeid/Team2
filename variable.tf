### VPC CIDR Block
variable "cidr_vpc" {
  description = "cidr range for VPC"
  type        = string
  default     = "100.192.0.0/16"
}

variable "cidr_subnet" {
  description = "cidr range for public VPC Subnet"
  type        = string
  default     = "100.192.1.0/24"
}

variable "k8s_name" {
  type        = string
  description = "cluster"
  default     = "k8cluster"
}

variable "ami" {
  description = "ubuntu machine image for nodes"
  type        = map(string)
  default = {
    master      = "ami-0e8d228ad90af673b"
    worker-node = "ami-0e8d228ad90af673b"
    jump-node   = "ami-0e8d228ad90af673b"
    dc-node   = "ami-0e8d228ad90af673b"
  }
}

variable "instance_type" {
  type = map(string)
  default = {
    master      = "t2.medium"
    worker-node = "t2.micro"
    jump-node   = "t2.micro"
    dc-node   = "t2.micro"
  }
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "public_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "key_name" {
  description = "keypair for the cluster"
  type        = string
  default     = "K8sKeypair"
}

variable "node_count" {
  description = "# of worker nodes"
  type        = number
  default     = 2
}


