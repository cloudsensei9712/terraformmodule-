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


variable "certificate_domain_name"{
  type        = string
  default     = null
  description = "Certificate Domain Name"
}

variable "certificate_alternate_domain_name"{
  type        = list(string)
  default     = null
  description = "List of alternate domain for certificate"

}

variable "certificate_validation_method" {
  type = string
  default = "DNS"
  description = "Validation method for the ACM Certificate"
}
