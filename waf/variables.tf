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
  default = "Northbay"
}

variable "waf_count" {
  type = number
}
variable "waf_name" {
  type = list(string)
}
variable "waf_scope" {
  type = list(string)
}
# variable "resource_arn" {
#   type = list(string)
# }
