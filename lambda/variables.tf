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

variable "lambda_functions_count" {
  type = number
}

variable "lambda_function_name" {
  type = list(string)
  default = ["lambda1", "lambda2"]
}

variable "vpc_id" {
  type = string
  default = "nodejs14.x"
}

variable "lambda_function_handler" {
  type = list(string)
  default = ["index.handler","index.handler"]
}

variable "lambda_function_runtime" {
  type = list(string)
  default = ["nodejs14.x","nodejs14.x"]
}

variable "lambda_function_s3_bucket" {
  type = string
}

variable "lambda_layer_s3_key" {
  type = list(string)
}
variable "lambda_function_s3_key" {
  type = list(string)
}


variable "lambda_function_subnets" {
  type = list(string)
}

variable "lambda_function_security_group" {
  type = list(string)
}

variable "lambda_role" {
  type = string
}