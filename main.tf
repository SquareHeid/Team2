# Create keypair
resource "aws_key_pair" "k8s_key_pair" {
  key_name   = var.key_name
  public_key = file(var.public_key)
}
