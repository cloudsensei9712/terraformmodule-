variable "name" {
  type        = string
  description = "Name of the bucket"
}

variable "environment" {
  type        = string
  description = "Name of the environment"
}

#variable "logging_bucket_name" {
#  type        = string
#  description = "The name of the bucket that stores access logs."
#}

variable "logging_prefix" {
  type        = string
  default     = ""
  description = "[Optional] The logging prefix. Should be left blank unless you're importing a bucket that uses a non-default value"
}

variable "policy" {
  type        = string
  default     = ""
  description = "[Optional] A json policy for the bucket"
}

variable "bucket_name" {
  type        = string
  default     = ""
  description = "[Optional] Used to support legacy buckets"
}

variable "block_public_acls" {
  type    = string
  default = "true"
}

variable "block_public_policy" {
  type    = string
  default = "true"
}

variable "ignore_public_acls" {
  type    = string
  default = "true"
}

variable "restrict_public_buckets" {
  type    = string
  default = "true"
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "[Optional] Used for SSE-KMS"
}

variable "versioning_enabled" {
  default     = "true"
  type        = string
  description = "Enable versioning. Versioning is a means of keeping multiple variants of an object in the same bucket."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "[Optional] AWS resource tags to add to the bucket"
}

variable "object_expiry_days" {
  type        = number
  default     = 0
  description = "[Optional] How long to store objects for before they're deleted"
}

variable "object_lock_enabled" {
  type        = bool
  default     = false
  description = "[Optional] Enable object lock for this bucket"
}

variable "object_lock_rule_retention_mode" {
  type        = string
  default     = null
  description = "[Optional] Object lock rule's retention mode to use. Example: GOVERNANCE"
}

variable "object_lock_rule_retention_days" {
  type        = string
  default     = null
  description = "[Optional] Object lock rule's retention period in days."
}

variable "cors_rules" {
  type        = string
  default     = "[]"
  description = "[Optional] json-encoded list of cors rules for the bucket"
}

variable "allowed_object_reader_arns" {
  type        = list(string)
  default     = []
  description = "[Optional] Use an allowlist of what ARNs are able to read data from this bucket. All other principals (including Admins) will be blocked from reading the data."
}

variable "acceleration_status" {
  type        = string
  default     = null
  description = "The s3 bucket acceleration status"
}
