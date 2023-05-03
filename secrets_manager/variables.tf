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

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region."
}
variable "aws_account_id" {
  type        = string
  default     = ""
  description = "AWS Account id."
}
variable "tags" {
  type    = map(any)
  default = {
    "project" = "foundant"
    "env"     = "beta"
    "iac"     = "terraform"
  }
  description = "Map of tags to assign to the resources."
}

#Secrets Manager
variable "secret_count" {
  type        = number
  default     = 1
  description = "Set to 0 to prevent the module from creating any resources."
}
variable "secret_version_enabled" {
  type        = list(bool)
  default     = false
  description = "Set to false to prevent creating secret version."
}
variable "secret_recovery_window_in_days" {
  type        = number
  default     = 7
  description = "Set to false to prevent creating secret version."
}
variable "secret_name" {
  type        = list(string)
  default     = "secret_name"
  description = "Name of the secret."
}
variable "secret_description" {
  type        = list(string)
  default     = ""
  description = "Description of the secret."
}
variable "secret_kms_key_id" {
  type        = list(string)
  default     = ""
  description = "KMS key ID for encrypting secret."
}
variable "secret_string" {
  type        = list(string)
  default     = ""
  description = "Secret value of the secret."
}