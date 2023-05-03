resource "aws_db_subnet_group" "age_db_subnet_group" {
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = var.privateSubnets
  tags = {
    Name = "${var.project}-${var.environment}-db-subnet-group"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

data "aws_ssm_parameter" "database_username" {
  name = var.dbUsernameParameter
}

data "aws_ssm_parameter" "database_password" {
  name = var.dbPasswordParameter
}

resource "aws_db_instance" "age_db" {
  allocated_storage                 = var.dbAllocatedStorage
  allow_major_version_upgrade       = false
  apply_immediately                 = false
  auto_minor_version_upgrade        = false
  backup_retention_period           = var.dbBackupRetentionPeriod
  backup_window                     = var.dbBackupWindow
  copy_tags_to_snapshot             = true
  db_subnet_group_name              = aws_db_subnet_group.age_db_subnet_group.name
  delete_automated_backups          = var.dbDeleteAutomatedBackups
  deletion_protection               = var.dbDeletionProtection
  enabled_cloudwatch_logs_exports   = var.dbEnabledCloudwatchLogsExports
  engine                            = var.dbEngine
  engine_version                    = var.dbEngineVersion
  identifier                        = "${var.project}-${var.environment}-db"
  instance_class                    = var.dbInstanceClass
  monitoring_interval               = var.dbMonitoringInterval
  monitoring_role_arn               = var.dbMonitoringRoleArn
  multi_az                          = var.dbMultiAZ
  name                              = var.dbInitialDatabseName
  username                          = data.aws_ssm_parameter.database_username.value
  password                          = data.aws_ssm_parameter.database_password.value
  port                              = var.dbPort
  storage_type                      = var.dbStorageType
  vpc_security_group_ids            = var.dbSecurityGroupId
  skip_final_snapshot               = true
  tags = {
    Name = "${var.project}-${var.environment}-db"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}