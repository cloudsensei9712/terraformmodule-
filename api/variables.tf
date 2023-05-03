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
variable "lambda_function_invoke_arn" {
  type = list(string)
}

variable "lambda_function_name" {
  type = list(string)
}