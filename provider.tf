
data "aws_eks_cluster" "eks_al2" {
  name = module.eks_al2.cluster_name
}

data "aws_eks_cluster_auth" "eks_al2" {
  name = data.aws_eks_cluster.eks_al2.name
}

provider "helm" {
  kubernetes {
      host                   = module.eks_al2.cluster_endpoint
      cluster_ca_certificate = base64decode(module.eks_al2.cluster_certificate_authority_data)
      token                  = data.aws_eks_cluster_auth.eks_al2.token
      }
}
# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

provider "kubernetes" {
  host                   = module.eks_al2.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_al2.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_al2.token
}



terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "webapp-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-1"

    dynamodb_table = "default-terraform-state-locks"
    encrypt        = true
  }
}