terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket  = "terraform-state-kindred"
    key     = "kindred/terraform.tfstate"
    region  = "us-east-1"
    profile = "kindred"
    # Used to lock file updates when sharing with multiple poeple. 
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

data "aws_ami" "app" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # canonical official
}

module "ec2_app" {
  source = "./modules/ec2"

  infra_env                 = var.infra_env
  infra_role                = "app"
  instance_size             = "t2.micro"
  instance_ami              = data.aws_ami.app.id
  instance_root_device_size = 12 # Optional
  subnets                   = keys(module.vpc.vpc_public_subnets)
  security_groups           = ["sg-0adbfe277a8b25e33"]
  tags = {
    Name = "kindred-${var.infra_env}-app"
  }
  create_eip = true
}

module "vpc" {
  source = "./modules/vpc"

  infra_env = var.infra_env
  vpc_cidr  = "10.0.0.0/18"
}