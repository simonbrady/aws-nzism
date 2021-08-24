variable "bucket_name" {
  type        = string
  description = "(Optional) Name of S3 bucket to create for config recorder to write to"
  default     = null
}

variable "create_recorder" {
  type        = bool
  description = "Set to true to create configuration recorder"
}

variable "conformance_pack_name" {
  type        = string
  description = "Name for assigned conformance pack"
}

variable "region" {
  type        = string
  description = "Region to create resources in"
}

variable "template_s3_uri" {
  type        = string
  description = "S3 URI for uploaded conformance pack template"
}
