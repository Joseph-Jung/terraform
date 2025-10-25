# Lambda Function Outputs
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.hello_world.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.hello_world.arn
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.hello_world.invoke_arn
}

output "lambda_function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.hello_world.version
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_apigatewayv2_api.hello_world_api.id
}

output "api_gateway_endpoint" {
  description = "Default endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.hello_world_api.api_endpoint
}

output "api_gateway_invoke_url" {
  description = "Full invoke URL for the API Gateway stage"
  value       = "${aws_apigatewayv2_api.hello_world_api.api_endpoint}/${aws_apigatewayv2_stage.default.name}"
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_apigatewayv2_stage.default.name
}

# CloudWatch Outputs
output "lambda_log_group_name" {
  description = "Name of the CloudWatch Log Group for Lambda"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}

output "api_gateway_log_group_name" {
  description = "Name of the CloudWatch Log Group for API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway_log_group.name
}

# Testing URL
output "test_curl_command" {
  description = "Curl command to test the API"
  value       = "curl ${aws_apigatewayv2_api.hello_world_api.api_endpoint}/${aws_apigatewayv2_stage.default.name}/"
}
