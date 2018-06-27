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