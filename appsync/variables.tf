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

variable "lambda_function_s3_bucket" {
  type = string
}


variable "lambda_function_s3_key" {
  type = string
}
