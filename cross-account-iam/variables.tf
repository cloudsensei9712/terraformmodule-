variable "project" {
  type    = string
  default = "partner-analytics"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "createdBy" {
  type    = string
  default = "slalom"
}

variable "eks_oidc_url" {
type    = string
  default = null
}

variable "service_account_name" {
  type    = string
  default = null
}

variable "kubernetes_namespace" {
  type    = string
  default = null
}

variable "additional_oidc_subs" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
