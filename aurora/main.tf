resource "aws_rds_cluster" "cluster" {
  cluster_identifier  = "${var.environment}-${var.project}-${var.cluster_identifier}"
  engine              = "aurora-mysql"
  engine_version      = var.engine_version
  availability_zones  = var.cluster_az_list
  database_name       = var.cluster_database_name
  master_username     = var.cluster_master_uname
  master_password     = var.cluster_master_passwd
  deletion_protection = var.cluster_enable_deletion_protection
  port                = var.cluster_port
  # Serverless
  engine_mode          = "serverless"
  enable_http_endpoint = var.cluster_enable_http_endpoint

  # Bckup & Maintaince
  preferred_backup_window      = var.cluster_backup_window
  preferred_maintenance_window = var.cluster_maintenance_window
  skip_final_snapshot          = var.cluster_skip_final_snaphot
  final_snapshot_identifier    = "${var.environment}-${var.project}-${var.cluster_identifier}-final-snapshot"
  # Scaling
  scaling_configuration {
    max_capacity = var.cluster_max_capacity
    min_capacity = var.cluster_min_capacity
  }

  tags = var.tags

}

resource "aws_security_group" "cache_sg" {
  name   = "${var.environment}-${var.cluster_identifier}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow Cnnection within VPC"
    from_port   = var.cluster_port
    to_port     = var.cluster_port
    protocol    = "tcp"
    cidr_blocks = var.cidr_list
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = var.tags
}


