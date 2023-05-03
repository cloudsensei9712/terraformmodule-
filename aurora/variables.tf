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

variable "cluster_identifier" {
  type    = string
  default = null
}

variable "engine_version" {
  type    = string
  default = "5.7.mysql_aurora.2.10.2"
}

variable "cluster_az_list" {
  type    = list(string)
  default = null
}

variable "cluster_database_name" {
  type    = string
  default = null
}

variable "cluster_master_uname" {
  type    = string
  default = null
}

variable "cluster_master_passwd" {
  type    = string
  default = null
}

variable "cluster_enable_deletion_protection" {
  type    = bool
  default = false
}

variable "cluster_enable_http_endpoint" {
  type    = bool
  default = false
}


variable "cluster_port" {
  type    = number
  default = 3306
}

variable "cluster_backup_window" {
  type    = string
  default = "00:00-01:00"
}

variable "cluster_maintenance_window" {
  type    = string
  default = "sun:00:00-sun:01:00"
}

variable "cluster_min_capacity" {
  type    = number
  default = 2
}


variable "cluster_max_capacity" {
  type    = number
  default = 4
}

variable "cidr_list" {
  type    = list(string)
  default = null
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "cluster_skip_final_snaphot" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}