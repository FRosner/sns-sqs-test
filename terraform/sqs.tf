resource "aws_sqs_queue" "upload" {
  name = "sns-sqs-upload"
}

resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = "${aws_sns_topic.upload.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.upload.arn}"
}

resource "aws_sqs_queue_policy" "test" {
  queue_url = "${aws_sqs_queue.upload.id}"
  policy = "${data.aws_iam_policy_document.sqs_upload.json}"
}

data "aws_iam_policy_document" "sqs_upload" {
  policy_id = "__default_policy_ID"
  statement {
    actions = [
      "sqs:SendMessage",
    ]
    condition {
      test = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        "${aws_sns_topic.upload.arn}",
      ]
    }
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "*"]
    }
    resources = [
      "${aws_sqs_queue.upload.arn}",
    ]
    sid = "__default_statement_ID"
  }
}