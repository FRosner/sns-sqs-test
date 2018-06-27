variable "aws_s3_bucket_upload_name" {
  default = "sns-sqs-upload-bucket"
}

resource "aws_s3_bucket" "upload" {
  bucket = "${var.aws_s3_bucket_upload_name}"
  acl    = "public-read"
  force_destroy = true
}

resource "aws_iam_access_key" "upload" {
  user    = "${aws_iam_user.upload.name}"
}

resource "aws_iam_user" "upload" {
  name = "sns-sqs-upload"
  path = "/system/"
}

resource "aws_iam_user_policy" "upload" {
  name = "sns-sqs-test"
  user = "${aws_iam_user.upload.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.upload.bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket_notification" "upload" {
  bucket = "${aws_s3_bucket.upload.id}"

  topic {
    topic_arn     = "${aws_sns_topic.upload.arn}"
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".jpeg"
  }
}