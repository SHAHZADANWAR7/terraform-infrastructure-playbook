# Configure the core Terraform settings and version requirements
terraform {
  required_version = ">= 1.0.0"
  
  # Declare required third-party provider plugins (AWS)
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider and target deployment region
provider "aws" {
  region = "us-east-1"
}
