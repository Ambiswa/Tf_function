resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": "sts:AssumeRole",
	  "Principal": {
		"Service": "lambda.amazonaws.com"
	  },
	  "Effect": "Allow",
	  "Sid": ""
	}
  ]
}
EOF
}
resource "aws_iam_role_policy" "Aws-S3-policy" {
  name = "Aws-S3-policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "Aws-cloudwatch-policy" {
  name = "Aws-cloudwatch-policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": [
		  "autoscaling:Describe*",
		  "cloudwatch:*",
		  "logs:*",
		  "sns:*",
		  "iam:GetPolicy",
		  "iam:GetPolicyVersion",
		  "iam:GetRole"
		],
	  "Effect": "Allow",
	  "Resource": "*"
	},
	{
	  "Effect": "Allow",
	  "Action": "iam:CreateServiceLinkedRole",
	  "Resource": "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
	  "Condition": {
	      "StringLike": {
		  "iam:AWSServiceName": "events.amazonaws.com"
		  }
		}
	}
  ]
}
EOF
}

data "archive_file" "init"{
    type ="zip"
    source_file = "lambda_function_payload.py"
    output_path = "outputs/lambda_function_payload.zip"
}
resource "aws_lambda_function" "func" {
  filename      = data.archive_file.init.output_path
  #filename      = "lambda_function_payload.zip"
  function_name = "Nw_lmbda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function_payload.lambda_handler" #file_name.method_name
  source_code_hash = filebase64sha256(data.archive_file.init.output_path)
  #source_code_hash = filebase64sha256("lambda_function_payload.zip")
  runtime = var.runtime
}
resource "aws_s3_bucket" "bucket" {
  bucket = "newbuckky1"
}
#resource "aws_s3_bucket_public_access_block" "bucket" {
#  bucket = aws_s3_bucket.bucket.id
  
 # block_public_acls   = true
  #block_public_policy = true
  #ignore_public_acls = true
  #restrict_public_buckets = true
#}
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.func.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}
