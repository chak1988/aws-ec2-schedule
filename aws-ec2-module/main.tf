locals {
  scheduler_actions = {
    stop  = var.stop_cron_schedule
    start = var.start_cron_schedule
  }
  tags = var.common_tags
}
#--------------- Lambda---------------------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "lambda_function.zip"
  source {
    filename = "lambda_function.py"
    content  = file("${path.module}/main.py")
  }
}

resource "aws_lambda_function" "ec2" {
  for_each         = local.scheduler_actions
  function_name    = "${var.name}-to-${each.key}"
  description      = "Lambda to ${each.key} EC2 Instances with specific Tag"
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  filename         = "lambda_function.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  tags             = local.tags
  timeout          = 10

  #environment variables that are accessible to the Lambda function code
  environment {
    variables = {
      EC2TAG_KEY   = var.stopstart_tags["TagKEY"]
      EC2TAG_VALUE = var.stopstart_tags["TagVALUE"]
      EC2_ACTION   = upper(each.key)
    }
  }
}


#--------------- Lambda IAM Permissions-----------------------------------------
resource "aws_iam_role" "lambda" {
  name               = "${var.name}-iam-role"
  tags               = local.tags
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda" {
  name   = "${var.name}-policy"
  tags   = local.tags
  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid"   : "LoggingPermissions",
              "Effect": "Allow",
              "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
              ],
              "Resource": [
                  "arn:aws:logs:*:*:*"
              ]
          },
          {
              "Sid"   : "WorkPermissions",
              "Effect": "Allow",
              "Action": [
                  "ec2:DescribeInstances",
                  "ec2:StopInstances",
                  "ec2:StartInstances"
              ],
              "Resource": "*"
          }
      ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "${var.name}-role-policy-attach"
  roles      = [aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.lambda.arn
}

#---------------Logging---------------------------------------------------------
resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = local.scheduler_actions
  name              = "/aws/lambda/${var.name}-to-${each.key}"
  retention_in_days = 7
  tags              = local.tags
}

#--------------- Lambda Triggers------------------------------------------------
resource "aws_cloudwatch_event_rule" "ec2" {
  for_each            = local.scheduler_actions
  name                = "${var.name}-trigger-to-${each.key}-ec2"
  description         = "Invoke Lambda using AWS EventBridge"
  schedule_expression = each.value
  tags                = local.tags
}

resource "aws_lambda_permission" "ec2" {
  for_each      = local.scheduler_actions
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2[each.key].arn
}

resource "aws_cloudwatch_event_target" "ec2" {
  for_each = local.scheduler_actions
  rule     = aws_cloudwatch_event_rule.ec2[each.key].name
  arn      = aws_lambda_function.ec2[each.key].arn
}
