terraform {
  backend "s3" {
    bucket         = "brains-backend"
    key            = "examples/vpc-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb_lock"
    encrypt        = true
  }
}
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Owner       = "X-as-Code"
      Environment = "Staging"
    }

  }
}

data "aws_availability_zones" "available_azs" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available_azs.names, 0, 2)
}

module "microservices-vpc" {
  # source = "github.com/osemiduh/aws-networking-modules//modules/vpc?ref=v0.1.2"
  source         = "../../modules/vpc"
  vpc_name       = "microservice-vpc"
  vpc_cidr_block = "10.0.0.0/21"
  azs = local.azs
  public_subnets = ["10.0.0.0/24","10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]


  enable_single_nat      = true
  one_nat_gateway_per_subnet = false
}

/*
resource "aws_route" "private_route" {
  route_table_id            = module.vpc-app-mgmt-datastore.private_route_table_id.id
  destination_cidr_block    = "0.0.0.0/1"
  nat_gateway_id = module.vpc-app-mgmt-datastore.nat_gatway_id
  depends_on                = [module.vpc-app-mgmt-datastore.private_route_table_id]
}

*/