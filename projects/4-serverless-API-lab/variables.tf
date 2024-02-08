variable "dynamo_name" {
  description = "Name of DynamoDB table"
  type        = string
  default     = "MyDynamoDBTable"
}

variable "lambda_function_name" {
  description = "Name of Lambda function"
  type        = string
  default     = "MyLambdaFunction"
}