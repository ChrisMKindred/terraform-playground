terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-kindred"
    key            = "kindred/terraform.tfstate"
    region         = "us-east-1"
    profile        = "kindred"
    dynamodb_table = "terraform-state-kindred"
  }
}

provider "aws" {
  profile = "kindred"
  region  = "us-east-1"
}

variable "infra_env" {
  type        = string
  description = "infrastructure environment"
}

variable "default_region" {
  type        = string
  description = "the region this infrastructure is in"
  default     = "us-east-1"
}

variable "instance_size" {
  type        = string
  description = "ec2 web server size"
  default     = "t2.micro"
}

# data "aws_ami" "app" {
#   most_recent = true

#   filter {
#     name   = "image-id"
#     values = ["ami-0fc5d935ebf8bc3bc"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }

#   owners = ["099720109477"] # canonical official
# }

resource "aws_instance" "kindred_web" {
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = var.instance_size

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = 8 # GB
    volume_type = "gp3"
  }

  tags = {
    Name        = "kindred-${var.infra_env}-web"
    Project     = "kindred.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip" "app_eip" {
  vpc = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "kindred-${var.infra_env}-web-address"
    Project     = "kindred.io"
    Environment = "staging"
    ManagedBy   = "terraform"
  }
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id   = aws_instance.kindred_web.id
  allocation_id = aws_eip.app_eip.id
}