
# ==============================================================================
# FILE: variables.tf
# PURPOSE: Input variables and parameterization setup.
# DESCRIPTION: 
#   This file acts as our settings panel. Instead of hardcoding values directly 
#   inside our main blueprint, we declare configurable parameters here so they 
#   can be easily modified across different deployments or environments.
# ==============================================================================

# Defines the target geographical AWS data center region
variable "aws_region" {
  type        = string
  description = "The target AWS region for resource deployment"
  default     = "us-east-1"
}

# Defines the target deployment environment context (e.g., development, staging, production)
variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
}
