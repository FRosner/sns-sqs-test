## Description

Showcase on synchronous and asynchronous event processing using AWS SNS, AWS SQS and AWS Lambda.

To run this demo, please build the artifacts first, then deploy the infrastructure.

## Build

```bash
sbt assembly
```

## Deploy

```bash
cd terraform
terraform init
terraform apply
```

## Usage

- Make sure the artifacts are built and the infrastructure is deployed.
- Configure an [incoming webhook](https://api.slack.com/incoming-webhooks) on Slack.
- Upload a [new file](https://s3.console.aws.amazon.com/s3/buckets/sns-sqs-upload-bucket/?region=eu-central-1&tab=overview) to the bucket. It needs to be a `*.jpeg` file.
- Receive Slack notification.
   ![notification](https://user-images.githubusercontent.com/3427394/41969768-c61a6a7a-7a08-11e8-9352-83f0e1f1bd63.png)

 

