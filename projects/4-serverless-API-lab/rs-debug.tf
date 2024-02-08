### Logging of API Calls
resource "aws_cloudwatch_log_group" "api_lambda" {
  name              = "lambda/${var.lambda_function_name}"
  retention_in_days = 14
}