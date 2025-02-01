# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  region_models = {
    "us-east-1" = var.default_model
  }
}

# Random password for API key
resource "random_password" "api_key" {
  length           = 32
  special          = true
  override_special = "-_"
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
}

# SSM Parameter for API key
resource "aws_ssm_parameter" "api_key" {
  name        = coalesce(var.api_key_param, "/bedrock-proxy/api-key")
  description = "API Key for Bedrock Proxy"
  type        = "SecureString"
  value       = random_password.api_key.result
}

output "api_key_parameter_arn" {
  description = "ARN of the SSM Parameter storing the API key"
  value       = aws_ssm_parameter.api_key.arn
}