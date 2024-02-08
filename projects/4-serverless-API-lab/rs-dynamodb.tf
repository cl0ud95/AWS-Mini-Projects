resource "aws_dynamodb_table" "my_dynamodb_table" {
  name           = var.dynamo_name
  hash_key       = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "id"
    type = "S"
  }
}

