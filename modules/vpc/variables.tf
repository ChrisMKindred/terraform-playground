variable "infra_env" {
  type        = string
  description = "infrastructure environment"
}

variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_numbers" {
  type = map(number)

  description = "Map of AZ to a number that should be used for public subnets."

  default = {
    "us-east-1a" = 1
    "us-east-1b" = 2
    "us-east-1c" = 3
    "us-east-1d" = 4
    "us-east-1e" = 5
    "us-east-1f" = 6
  }
}

variable "private_subnet_numbers" {
  type = map(number)

  description = "Map of AZ to a number that should be used for private subnets."

  default = {
    "us-east-1a" = 7
    "us-east-1b" = 8
    "us-east-1c" = 9
    "us-east-1d" = 10
    "us-east-1e" = 11
    "us-east-1f" = 12
  }
}