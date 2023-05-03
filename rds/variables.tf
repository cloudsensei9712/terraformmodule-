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

variable "privateSubnets" {
  type = list(string)
  description = "List of private subnet Ids to create subnet group"
}

variable "dbAllocatedStorage" {
  type = number
  default = 50
  description = "Storage allocated to database in gigabytes (GB)"
}

variable "dbBackupRetentionPeriod" {
  type = number
  default = 0
  description = "Number of days to retain backups for databse, value must be between 0 and 35"
}

variable "dbBackupWindow" {
  type = string
  default = "04:00-04:30"
  description = "Daily time range (in UTC) during which automated backups are created if they are enabled."
}

variable "dbDeleteAutomatedBackups" {
  type = bool
  default = true
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted"
}

variable "dbDeletionProtection" {
  type = bool
  default = false
  description = "Enable or disable deletion protection on the database instance"
}

variable "dbEnabledCloudwatchLogsExports" {
  type = list(string)
  default = ["audit", "error", "general", "slowquery"]
  description = "Set of log types to enable for exporting to CloudWatch logs"
}

variable "dbEngine" {
  type = string
  default = "mysql"
  description = "Database engine to be used rds instance"
}

variable "dbEngineVersion" {
  type = string
  default = "8.0.20"
  description = "The engine version to use"
}

variable "dbInstanceClass" {
  type = string
  default = "db.t2.micro"
  description = "The instance type of the RDS instance"
}

variable "dbInitialDatabseName" {
  type = string
  default = "AGE"
  description = "The name of the database to create when the DB instance is created"
}

variable "dbMonitoringInterval" {
  type = number
  default = 0
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
}

variable "dbMonitoringRoleArn" {
  type = string
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
}

variable "dbMultiAZ" {
  type = bool
  default = false
  description = "Specifies if the RDS instance is multi-AZ"
}

variable "dbUsernameParameter" {
  type = string
  default = ""
  description = "Username for the master DB user."
  sensitive = true
}

variable "dbPasswordParameter" {
  type = string
  default = ""
  description = "Password for the master DB user."
  sensitive = true
}

variable "dbPort" {
  type = string
  default = "3306"
  description = "The port on which the DB accepts connections"
}

variable "dbStorageType" {
  type = string
  default = "gp2"
  description = "One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD)"
}

variable "dbSecurityGroupId" {
  type = list(string)
  description = "List of VPC security groups to associate."
}

