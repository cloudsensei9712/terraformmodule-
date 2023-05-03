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
  default = "NT"
}

variable "table_name" {
  type = string
  default = "table"
}

variable "table_read_capacity" {
  type = number
  default = 10
}

variable "table_write_capacity" {
  type = number
  default = 10
}

variable "table_hash_key" {
  type = string
  default = "id"
}

variable "table_range_key" {
  type = string
  default = "id"
}

variable "table_billing_mode" {
  type = string
}
