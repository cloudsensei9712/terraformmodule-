variable "project" {
  type        = string
  default     = "northbay"
  description = "Name of the project."
}
variable "env" {
  type        = string
  default     = "dev"
  description = "Name of the Environment."
}
variable "app" {
  type        = string
  default     = ""
  description = "Application name."
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
    "project" = "northbay"
    "env"     = "dev"
    "iac"     = "terraform"
  }
  description = "Map of tags to assign to the resources."
}

#AD
variable "ad_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}
variable "ad_full_name" {
  type        = string
  default     = ""
  description = "AD full name."
}
variable "ad_short_name" {
  type        = string
  default     = "ad"
  description = "AD short name e.g ad."
}
variable "ad_type" {
  type        = string
  default     = "MicrosoftAD"
  description = "Type of AD."
}
variable "ad_edition" {
  type        = string
  default     = "Standard"
  description = "Edition of AD."
}
variable "ad_size" {
  type        = string
  default     = "Small"
  description = "Ad size Valid: Small, Large."
}
variable "ad_vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for AD."
}
variable "ad_subnet_id_list" {
  type        = list(string)
  default     = []
  description = "Subnet id to launch AD in."
}
variable "ad_password_secrets_arn" {
  type        = string
  default     = ""
  description = "Secrets manager ARN for AD password."
}
