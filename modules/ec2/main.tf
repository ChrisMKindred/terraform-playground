resource "random_shuffle" "subnets" {
  input        = var.subnets
  result_count = 1
}

resource "aws_instance" "kindred_web" {
  ami           = var.instance_ami
  instance_type = var.instance_size

  root_block_device {
    volume_size = var.instance_root_device_size
    volume_type = "gp3"
  }

  subnet_id              = random_shuffle.subnets.result[0]
  vpc_security_group_ids = var.security_groups

  tags = merge({
    Name        = "kindred-${var.infra_env}-${var.infra_role}"
    Role        = var.infra_role
    Project     = "kindred.dev"
    Environment = var.infra_env
    ManagedBy   = "terraform"
    },
    var.tags
  )
}

resource "aws_eip" "kindred_addr" {
  count = (var.create_eip) ? 1 : 0
  # We're not doing this directly
  # instance = aws_instance.kindred_web.id
  vpc = true

  lifecycle {
    # prevent_destroy = true
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
  count = (var.create_eip) ? 1 : 0

  instance_id   = aws_instance.kindred_web.id
  allocation_id = aws_eip.kindred_addr[0].id
}