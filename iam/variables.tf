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

variable "awsRegion" {
  type = string
  default = "us-west-1"
  description = "Current AWS Region"
}

variable "awsAccountId" {
  type = string
  default = "us-west-1"
  description = "Current AWS Region"
}

variable "codeBuildLogGroupName" {
  type = string
  default = "/codebuild/age/build"
  description = "Cloud Watch Logr Group Name for the Code Build"
}