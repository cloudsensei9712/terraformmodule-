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

variable "vpcId" {
  description = "ID of the VPC."
}
variable "albSubnetIds" {
  description = "Subnet IDs where ALB should route traffic to."
}

variable "albSSLPolicy" {
  type = string
  default = "ELBSecurityPolicy-2016-08"
  description = "Name of the SSL Policy for the listener."
}

variable "albSSLCertificateArn" {
  type = string
  description = "ARN of the default SSL server certificate"
}

variable "albSecurityGroupId" {
  type = list(string)
  description = "A list of security group IDs to assign to the LB"
}

variable "appTargetGroupPort" {
  type = number
  default = 80
  description = "Port of the target group for app servers."
}

variable "albIdleTimeout" {
  type = number
  default = 120
  description = "The time in seconds that the connection is allowed to be idle."
}