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

variable "region" {
        type = string
        default = "us-east-2"
}

variable "vpcAZs" {
        type = list(string)
        default = [ "us-east-2a", "us-east-2b" ]
}

variable "instanceTenancy" {
        type = string
        default = "default"
}

variable "dnsSupport" {
         default = true
}

variable "dnsHostNames" {
        default = true
}

variable "vpcCIDR" {
        type = string
        default = "150.100.0.0/16"
 
}

variable "publicSubnetCount" {
        type = number
        default = 1
}

variable "publicSubnetsCIDR" {
        type = list(string)
        default = [ "150.100.1.0/24", "150.100.2.0/24" ]
}

variable "privateSubnetCount" {
        type = number
        default = 1
}

variable "privateSubnetsCIDR" {
        type = list(string)
        default = [ "150.100.3.0/24", "150.100.4.0/24" ]
}

variable "destinationCIDR" {
        type = string
        default = "0.0.0.0/0"
}

variable "mapPublicIP" {
        default = true
}

variable "enablePrivateInternetAccess" {
  default = false
}

variable "enableDynamodbEndpoint" {
  default = false
}
variable "enableSnsEndpoint" {
  default = false
}
variable "enableSesEndpoint" {
  default = false
}