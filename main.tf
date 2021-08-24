terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_iam_service_linked_role" "config" {
  count            = var.create_recorder ? 1 : 0
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "config" {
  count    = var.create_recorder ? 1 : 0
  role_arn = aws_iam_service_linked_role.config[0].arn
}

resource "aws_s3_bucket" "config" {
  count  = var.create_recorder ? 1 : 0
  bucket = var.bucket_name
}

resource "aws_s3_bucket_policy" "config" {
  count  = var.create_recorder ? 1 : 0
  bucket = aws_s3_bucket.config[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = ["config.amazonaws.com"]
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config[0].arn
      },
      {
        Sid    = "AWSConfigBucketExistenceCheck"
        Effect = "Allow"
        Principal = {
          Service = ["config.amazonaws.com"]
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.config[0].arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = ["config.amazonaws.com"]
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config[0].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
    ]
  })
}

resource "aws_config_delivery_channel" "config" {
  count          = var.create_recorder ? 1 : 0
  depends_on     = [aws_config_configuration_recorder.config]
  s3_bucket_name = aws_s3_bucket.config[0].bucket
}

resource "aws_config_configuration_recorder_status" "config" {
  count      = var.create_recorder ? 1 : 0
  depends_on = [aws_config_delivery_channel.config]
  name       = aws_config_configuration_recorder.config[0].name
  is_enabled = true
}

resource "aws_config_conformance_pack" "nzism" {
  depends_on      = [aws_config_configuration_recorder.config]
  name            = var.conformance_pack_name
  template_s3_uri = var.template_s3_uri
}
