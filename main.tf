resource "aws_iam_role" "iam_for_step" {
  name = "iam_for_step"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Action": "sts:AssumeRole",
    "Principal": {
    "Service": "states.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": "StepFunctionAssumeRole"
  }
  ]
}
EOF
}
resource "aws_iam_role_policy" "Aws-step-policy" {
  name = "Aws-step-policy"
  role = aws_iam_role.iam_for_step.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:us-east-2:842146660626:function:Nw_lmbda"
    }
  ]
}
EOF
}
resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "Nw-state-machine"
  role_arn = aws_iam_role.iam_for_step.arn

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-2:842146660626:function:Nw_lmbda",
      "End": true
    }
  }
}
EOF
}
