variable "aws_s3_bucket_upload_name" {
  default = "sns-sqs-upload-bucket"
}

resource "aws_s3_bucket" "upload" {
  bucket = "${var.aws_s3_bucket_upload_name}"
  acl    = "public-read"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "upload" {
  bucket = "${aws_s3_bucket.upload.id}"

  topic {
    topic_arn     = "${aws_sns_topic.upload.arn}"
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".jpeg"
  }
}