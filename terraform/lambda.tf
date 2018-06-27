variable "slack_lambda_version" {
  type = "string"
  default = "0.1-SNAPSHOT"
}

locals {
  slack_lambda_artifact = "../slack/target/scala-2.12/sns-sqs-chat-assembly-${var.slack_lambda_version}.jar"
}

variable "slack_hook_url" {
  type = "string"
}

resource "aws_lambda_function" "slack" {
  function_name = "sns-sqs-upload-slack"
  filename = "${local.slack_lambda_artifact}"
  source_code_hash = "${base64sha256(file(local.slack_lambda_artifact))}"
  handler = "de.frosner.aws.slack.Handler"
  runtime = "java8"
  role = "${aws_iam_role.lambda_exec.arn}"
  memory_size = 1024
  timeout = 5

  environment {
    variables {
      hook_url = "${var.slack_hook_url}"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "sns-sqs-slack-lambda"

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

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = "${aws_sns_topic.upload.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.slack.arn}"
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.slack.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.upload.arn}"
}

resource "aws_iam_policy" "lambda_logging" {
  name = "sns-sqs-lambda-logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.lambda_exec.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}