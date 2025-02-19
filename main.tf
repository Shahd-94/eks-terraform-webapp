
locals {
  infra_env = terraform.workspace
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"
  name = "${local.infra_env}-main-vpc"
  cidr = "10.0.0.0/16"

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = [var.private_subnets[0].cidr_block, var.private_subnets[1].cidr_block]
  public_subnets = [var.public_subnets[0].cidr_block, var.public_subnets[1].cidr_block]

  create_igw = true # default
  enable_dns_hostnames = true # default

  enable_nat_gateway = true
  single_nat_gateway = true
  map_public_ip_on_launch = true
  one_nat_gateway_per_az = false
  create_private_nat_gateway_route = true # default

  tags = {
    Terraform = "true"
    Environment = "main"
  }
}

module "eks_al2" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.infra_env}-webapp-eks"
  cluster_version = "1.32"
  cluster_endpoint_public_access = true
  bootstrap_self_managed_addons = true
  create_cloudwatch_log_group = false
  create_kms_key = false
  authentication_mode = "API"
  enable_cluster_creator_admin_permissions = true
  enable_kms_key_rotation = false
  kms_key_enable_default_policy = false
  enable_irsa = false
  cluster_encryption_config  = {}
  create_node_security_group = true
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  control_plane_subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  eks_managed_node_groups = {
    group1 = {
      name = "${local.infra_env}-webapp-node"
      ami_type      = "AL2_x86_64"
      instance_type = "t2.medium"
      min_size = 2
      max_size = 2
      desired_size = 2
    }
  }

}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "${local.infra_env}-webapp-terraform-state"
 
  # Prevent accidental deletion of this S3 bucket
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform-state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public-access" {
  bucket                  = aws_s3_bucket.terraform-state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform-locks" {
  name         = "${local.infra_env}-terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}