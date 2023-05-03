variable "project" {
  type    = string
  default = null
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "created_by" {
  type    = string
  default = null
}

variable "s3_bucket" {
  type        = string
  description = "ARN of the S3 bucket to store flow logs"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "ID of the VPC to log"
}
variable "tags" {
  type = map(string)
  default = null
  description = "Tags for the resources"
}
