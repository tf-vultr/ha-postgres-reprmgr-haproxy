terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Default VPC Configuration ---

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.all.ids)
  id       = each.value
}

locals {
  # Group subnet IDs by AZ
  subnets_by_az = {
    for s in data.aws_subnet.details : s.availability_zone => s.id...
  }
  # Pick one subnet per AZ
  selected_subnets = values({for az, ids in local.subnets_by_az : az => ids[0]})
  
  common_tags = {
    Project = var.project_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
