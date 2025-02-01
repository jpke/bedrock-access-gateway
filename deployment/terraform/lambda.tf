# IAM roles and policies
resource "aws_iam_role" "proxy_api_handler_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.proxy_api_handler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "proxy_api_handler_policy" {
  name = var.lambda_policy_name
  role = aws_iam_role.proxy_api_handler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:ListFoundationModels",
          "bedrock:ListInferenceProfiles"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:*:*:inference-profile/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:GetParameterHistory"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.api_key_param}"
      }
    ]
  })
}

# Lambda function
resource "aws_lambda_function" "proxy_api_handler" {
  function_name    = var.lambda_function_name
  role            = aws_iam_role.proxy_api_handler_role.arn
  architectures    = ["arm64"]
  package_type     = "Image"
  image_uri        = "${var.ecr_account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.ecr_repository}:${var.ecr_image_tag}"
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout

  environment {
    variables = {
      API_KEY_PARAM_NAME            = var.api_key_param
      DEBUG                         = var.debug_mode
      DEFAULT_MODEL                 = lookup(local.region_models, data.aws_region.current.name, var.default_model)
      DEFAULT_EMBEDDING_MODEL       = var.default_embedding_model
      ENABLE_CROSS_REGION_INFERENCE = var.enable_cross_region_inference
    }
  }
}

resource "aws_lambda_permission" "alb_invoke" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.proxy_api_handler.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
} 