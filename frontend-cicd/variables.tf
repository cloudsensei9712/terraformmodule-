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


variable "front_end_repository" {
  type = string
}

variable "front_end_repository_branch" {
  type = string
}
variable "static_web_bucket_name" {
  type = string
  
}
variable "frontend_pipeline_role" {
  type = string
}
variable "frontend_codebuild_role" {
    type = string
}
variable "codestar_connection_arn" {
  type = string
}
variable "create_manual_approval" {
  type = bool
}