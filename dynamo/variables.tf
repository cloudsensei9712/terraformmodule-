variable "project" {
  type    = string
  default = null
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "created_by" {
  type    = string
  default = null
}

variable "table_name" {
  type    = string
  default = "table"
}

variable "table_read_capacity" {
  type    = number
  default = 10
}

variable "table_write_capacity" {
  type    = number
  default = 10
}

variable "table_hash_key" {
  type    = string
  default = "id"
}

variable "table_range_key" {
  type    = string
  default = "id"
}

variable "table_billing_mode" {
  type = string
}

variable "enable_pitr" {
  type    = bool
  default = false
}

variable "table_additional_attributes" {
  type        = map(string)
  description = "Map of attributes; each value points to its type e.g. FirstName = S"
}

variable "table_gsi" {
  type        = map(any)
  description = "Map of global secondary index information e.g. gsi = { Index1 = {hash_key = FirstName range_key =  LastName  projection_type = INCLUDE,non_key_attributes = [FirstName, LastName, ]} }"
}

variable "tags" {
  type    = map(string)
  default = null
}