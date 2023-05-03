variable "description" {
  description = "The description of the key as viewed in AWS console."
}

variable "key_usage" {
  description = "KMS key usage"
  default     = "ENCRYPT_DECRYPT"
}

variable "customer_master_key_spec" {
  description = "Key spec"
  default     = "SYMMETRIC_DEFAULT"
}

variable "alias" {
  description = "Optional alias for this key."
  default     = ""
}

variable "enable_sns" {
  description = "When set to true, will give allow this key to be used to encrypt SNS topics."
  default     = false
}

variable "enable_sqs" {
  description = "When set to true, will allow this key to be used to encrypt SQS queues."
  default     = false
}

variable "enable_s3" {
  description = "When set to true, will allow this key to be used by S3 to use encrypted SQS queues and SNS topics."
  default     = false
}

variable "additional_policy_json" {
  description = "Additional policy JSON to merge with the default policies provided by this module."
  default     = ""
  type        = string
}

variable "kms_iam_policy" {
  description = "Additional policy to merge with the default policies provided by this module."
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "allowed_accounts" {
  type    = list(string)
  default = []
}
