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
variable "parameter_count" {
  type = number
  default = 1
  description = "Number of Parameters to create"
}

variable"parameter_name" {
  type = list(string)
  description = "Names of parameters"
}
variable "parameter_type" {
  type = list(string)
  description = "Type of Parameters.  Valid types are String, StringList and SecureString.s"
}
variable "parameter_value" {
  type = list(string)
  description = "Values of Parameters"
}
variable "tags" {
  type    = map
  default = null
  description = "Additional tags."
}
