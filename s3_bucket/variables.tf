variable "project" {
  type = string
  default = "partner-analytics"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "created_by" {
  type = string
  default = ""
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "bucket_count" {
  type= number
  default = 1
}

variable "bucket_names"{
  type        = list(string)
  default     = null
  description = "S3 bucket names"
}

variable "bucket_versioning"{
  type        = bool
  default     = true
  description = "S3 bucket versioning"

}

variable "bucket_acls" {
  type        = list(string)
  default     = null
  description = "S3 bucket ACL (public or private)"
}

