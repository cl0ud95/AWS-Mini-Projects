### IAM policy and role creation

# policy documents for the role assumption and policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-apigateway-policy"
  description = "Policy for lambda for serverless project"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-apigateway-role"
  description        = "Role for lambda for serverless project"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_iam_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

### Grant permission to API gateway to invoke lambda function
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIExecutionOfLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.dynamo_api.execution_arn}/*/*"
}