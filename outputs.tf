# ==============================================================================
# FILE: outputs.tf
# PURPOSE: Output values and resource reference reporting.
# DESCRIPTION: 
#   This file acts as our report card. Once Terraform finishes provisioning 
#   our infrastructure, this file defines what key information or attribute IDs 
#   are displayed back to the user or made available to other modules.
# ==============================================================================

# Outputs the AWS region where the infrastructure was deployed
output "region" {
  description = "The target AWS deployment region"
  value       = var.aws_region
}

# Outputs the environment name for verification
output "environment" {
  description = "The current deployment environment context"
  value       = var.environment
}
