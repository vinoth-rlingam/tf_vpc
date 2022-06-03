provider "aws" {
  region = "eu-west-1"
}

data "aws_caller_identity" "current"{

}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"
  name                 = "k8-vpc-karpenter-${var.environ}"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  public_subnets       = ["10.0.107.0/24", "10.0.108.0/24", "10.0.109.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

locals {
  cluster_name = "eks-cluster-karpenter"
  tags = {
    EnvironmentType = "Dev"
    ServiceName = "karpenter"
    Owner = "Vinoth"
  }
}


