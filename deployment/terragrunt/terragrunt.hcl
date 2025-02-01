generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.env_vars.aws_region}"
  
  # Uncomment and modify these if you need to assume a role
  # assume_role {
  #   role_arn = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
  # }

  default_tags {
    tags = {
      Environment = "${local.environment}"
      Terraform   = "true"
      Project     = "${local.env_vars.project_name}"
      ModulePath  = "${local.modulePath}"
    }
  }
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in S3
remote_state {
  backend = "s3"
  config = {
    bucket         = "${local.env_vars.state_bucket}"
    key            = "${path_relative_to_include()}/bedrock-proxy/terraform.tfstate"
    region         = "${local.env_vars.aws_region}"
    encrypt        = true
    dynamodb_table = "${local.env_vars.state_lock_table}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
terraform {
  source = "../terraform"
}

locals {
  # Load environment variables from env.yaml
  env_vars = yamldecode(file("env.yaml"))
  environment = local.env_vars.environment
  modulePath  = path_relative_to_include()
}

inputs = {
  # Lambda configuration
  lambda_function_name = "bedrock-proxy-handler-${local.environment}"
  lambda_role_name    = "bedrock-proxy-lambda-role-${local.environment}"
  lambda_policy_name  = "bedrock-proxy-lambda-policy-${local.environment}"
  lambda_memory_size  = local.env_vars.lambda.memory_size
  lambda_timeout      = local.env_vars.lambda.timeout

  # ECR configuration
  ecr_account_id = local.env_vars.ecr.account_id
  ecr_repository = local.env_vars.ecr.repository
  ecr_image_tag  = local.env_vars.ecr.image_tag

  # VPC configuration
  vpc_id     = local.env_vars.vpc.id
  subnet_ids = local.env_vars.vpc.subnet_ids

  # ALB configuration
  alb_name               = "bedrock-proxy-${local.environment}"
  alb_port              = local.env_vars.alb.port
  security_group_name    = "bedrock-proxy-alb-sg-${local.environment}"
  target_group_name     = "bedrock-proxy-tg-${local.environment}"
  allowed_cidr_blocks   = local.env_vars.alb.allowed_cidr_blocks

  # Application configuration
  api_key_param                 = "bedrock-proxy-api-key-${local.environment}"
  debug_mode                    = local.env_vars.app.debug_mode
  default_model                = local.env_vars.app.default_model
  default_embedding_model      = local.env_vars.app.default_embedding_model
  enable_cross_region_inference = local.env_vars.app.enable_cross_region_inference
  enable_deletion_protection    = local.env_vars.app.enable_deletion_protection
} 