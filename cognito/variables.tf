variable "project" {
  type = string
  default = "age"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "createdBy" {
  type = string
  default = "NT"
}

variable "user_pool_name" {
  type = list(string)
  default = ["table"]
}

variable "user_pool_count" {
  type = number
  default = 1
}

variable "user_pool_mfa_configuration" {
  type = list(string)
  default =  [ "OPTIONAL" ]
}

variable "user_pool_domain_name" {
  type = list(string)
  default =  ["alumini" ]
}

variable "use_custom_ses" {
  type = list(bool)
}
variable "ses_endpoint_arn" {
  type = list(string)
}