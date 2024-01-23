resource "aws_api_gateway_rest_api" "dynamo_api" {
  name        = "DynamoDBOperations"
  description = "For serverless project"
}

locals {
  api_id = aws_api_gateway_rest_api.dynamo_api.id
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = local.api_id
  parent_id   = aws_api_gateway_rest_api.dynamo_api.root_resource_id
  path_part   = "serverless"
}

resource "aws_api_gateway_method" "api_method" {
  rest_api_id   = local.api_id
  resource_id   = aws_api_gateway_resource.api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = local.api_id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.api_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY" #IMPT
  uri = aws_lambda_function.my_lambda_func.invoke_arn
}

# Creating deployment stage
resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = local.api_id
}

resource "aws_api_gateway_stage" "dev_stage" {
  rest_api_id   = local.api_id
  stage_name    = "dev"
  deployment_id = aws_api_gateway_deployment.api_deploy.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_lambda.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      status                  = "$context.status"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}