# ==============================================================================
# FILE: main.tf
# PURPOSE: Core resource definitions and cloud provider configurations.
# DESCRIPTION: 
#   This file serves as the main entry point for our Terraform project. 
#   It tells Terraform two essential things:
#     1. What version of Terraform and third-party providers (like AWS) to use.
#     2. Which cloud region we are deploying our infrastructure into (us-east-1).
# 
# LEARNING NOTE FOR BEGINNERS:
#   - Every Terraform project needs a `terraform {}` block to lock down versions.
#   - The `provider "aws"` block tells AWS CLI credentials where to build things.
# ==============================================================================

terraform {
  # Ensures anyone running this project uses Terraform version 1.0.0 or higher
  required_version = ">= 1.0.0"

  # Declares the required provider plugins (AWS in this case)
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures the connection to Amazon Web Services (AWS)
provider "aws" {
  region = "us-east-1"
}
