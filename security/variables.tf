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
  type = string
  description = "Id of the VPC to create Security Groups In"
}

variable "ingressCIDRblock" {
        type = list(string)
        default = [ "0.0.0.0/0" ]
}
