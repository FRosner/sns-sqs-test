## Usage

### Build

```bash
sbt assembly
```

### Deploy

```bash
cd terraform
terraform init
terraform apply
```

### S3 Upload

```sh
script/upload '<aws_access_key>' '<aws_secret_key>' \
  'sns-sqs-upload-bucket@eu-central-1' \
  /Users/frosner/Downloads/3427394.jpeg \
  /frank.jpeg \
  'public-read'
```