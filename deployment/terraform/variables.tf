variable "lambda_role_name" {
  type        = string
  description = "Name of the IAM role for the Lambda function"
  default     = "bedrock-proxy-lambda-role"
}

variable "lambda_policy_name" {
  type        = string
  description = "Name of the IAM policy for the Lambda function"
  default     = "bedrock-proxy-lambda-policy"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function"
  default     = "bedrock-proxy-handler"
}

variable "ecr_account_id" {
  type        = string
  description = "AWS account ID containing the ECR repository"
}

variable "ecr_repository" {
  type        = string
  description = "Name of the ECR repository"
}

variable "ecr_image_tag" {
  type        = string
  description = "Tag of the ECR image to deploy"
  default     = "latest"
}

variable "lambda_memory_size" {
  type        = number
  description = "Memory size for the Lambda function in MB"
  default     = 128
}

variable "lambda_timeout" {
  type        = number
  description = "Timeout for the Lambda function in seconds"
  default     = 30
}

variable "debug_mode" {
  type        = string
  description = "Enable debug mode for the Lambda function"
  default     = "false"
}

variable "default_model" {
  type        = string
  description = "Default Bedrock model to use"
  default     = "anthropic.claude-v2"
}

variable "default_embedding_model" {
  type        = string
  description = "Default embedding model to use"
  default     = "amazon.titan-embed-text-v1"
}

variable "enable_cross_region_inference" {
  type        = bool
  description = "Enable cross-region model inference"
  default     = false
}

variable "alb_name" {
  type        = string
  description = "Name of the Application Load Balancer"
  default     = "bedrock-proxy-alb"
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable deletion protection for the ALB"
  default     = false
}

variable "security_group_name" {
  type        = string
  description = "Name of the security group for the ALB"
  default     = "bedrock-proxy-alb-sg"
}

variable "alb_port" {
  type        = number
  description = "Port number for the ALB"
  default     = 80
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the ALB"
  default     = ["0.0.0.0/0"]
}

variable "target_group_name" {
  type        = string
  description = "Name of the ALB target group"
  default     = "bedrock-proxy-tg"
}

variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where the ALB will be deployed"
}

variable "api_key_param" {
  type        = string
  default     = ""
  description = "The parameter name in System Manager used to store the API Key, leave blank to use a default key"
}