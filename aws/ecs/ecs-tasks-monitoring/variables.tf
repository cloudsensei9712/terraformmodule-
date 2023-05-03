variable environment {}

variable "s3_bucket" {
  description = "S3 bucket name to be used by the lambda function"
  type = string
}

variable "s3_key" {
  description = "S3 object path to the actual code that the lambda handler uses"
  type = string
}

variable "existing_policy" {
  description = "Skip role creation if already exists - usually creaded in another region"
  type = bool
  default = false
}