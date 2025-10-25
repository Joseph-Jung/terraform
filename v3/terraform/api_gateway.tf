# HTTP API Gateway
resource "aws_apigatewayv2_api" "hello_world_api" {
  name          = "${var.lambda_function_name}-api"
  protocol_type = "HTTP"
  description   = "HTTP API for Hello World Lambda function"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.lambda_function_name}-api"
    }
  )
}

# API Gateway Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.hello_world_api.id
  name        = var.api_stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.lambda_function_name}-${var.api_stage_name}"
    }
  )
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name              = "/aws/apigateway/${var.lambda_function_name}-api"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.common_tags,
    {
      Name = "${var.lambda_function_name}-api-logs"
    }
  )
}

# Lambda Integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.hello_world_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.hello_world.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# API Gateway Route - GET /
resource "aws_apigatewayv2_route" "get_root" {
  api_id    = aws_apigatewayv2_api.hello_world_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# API Gateway Route - GET /hello
resource "aws_apigatewayv2_route" "get_hello" {
  api_id    = aws_apigatewayv2_api.hello_world_api.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# API Gateway Route - POST /
resource "aws_apigatewayv2_route" "post_root" {
  api_id    = aws_apigatewayv2_api.hello_world_api.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}
