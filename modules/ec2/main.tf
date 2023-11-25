resource "aws_instance" "kindred_web" {
  ami           = var.instance_ami
  instance_type = var.instance_size
 
  root_block_device {
    volume_size = var.instance_root_device_size
    volume_type = "gp3"
  }
 
  tags = {
    Name        = "kindred-${var.infra_env}-${var.infra_role}" 
    Role        = var.infra_role
    Project     = "kindred.dev"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}
 
resource "aws_eip" "kindred_addr" {
  # We're not doing this directly
  # instance = aws_instance.kindred_web.id
  vpc      = true
 
  lifecycle {
    prevent_destroy = true
  }
 
  tags = {
    Name        = "kindred-${var.infra_env}-${var.infra_role}-address"
    Role        = var.infra_role
    Project     = "kindred.dev"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}
 
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.kindred_web.id
  allocation_id = aws_eip.kindred_addr.id
}