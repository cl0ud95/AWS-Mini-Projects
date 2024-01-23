### Uploading source code to S3 Bucket and getting lambda function to read from the bucket
resource "random_pet" "s3_bucket_name" {
  prefix = "lambda"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = random_pet.s3_bucket_name.id
  force_destroy = true
}

# Making bucket private
resource "aws_s3_account_public_access_block" "lambda_bucket_block" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "archive_file" "python_zip" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/serverless_python.zip"
}

resource "aws_s3_object" "python_zip_upload" {

  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "serverless_python.zip"
  source = data.archive_file.python_zip.output_path

  etag = filemd5(data.archive_file.python_zip.output_path) # To trigger reupload if python code changes
}

resource "aws_lambda_function" "my_lambda_func" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.python_zip_upload.key

  handler          = "serverless_python.lambda_handler" # Must be named exactly the same as the function in the python file
  runtime          = "python3.12"
  source_code_hash = data.archive_file.python_zip.output_base64sha256
}