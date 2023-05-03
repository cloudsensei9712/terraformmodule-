# Create an alb security group which allows incoming http and https traffic
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "Allow Public traffic for ALB."
  vpc_id      = var.vpcId

  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    
  }

  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
	}
  tags = {
    Name = "${var.project}-${var.environment}-alb-sg"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

# Create an alb security group which allows incoming http and https traffic
resource "aws_security_group" "ecs_sg" {
  name        = "${var.project}-${var.environment}-ecs-sg"
  description = "Allow  traffic for ALB."
  vpc_id      = var.vpcId

  ingress {
    security_groups = [ aws_security_group.alb_sg.id ]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    
  }

  ingress {
    security_groups = [ aws_security_group.alb_sg.id ]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
	}
  tags = {
    Name = "${var.project}-${var.environment}-ecs-sg"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id       = var.vpcId
  name         = "${var.project}-${var.environment}-rds-sg"
  description  = "Security for the RDS DB Instance"
	
  ingress {
    security_groups = [ aws_security_group.ecs_sg.id ]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }
 
  egress {
	protocol = -1
	from_port = 0 
	to_port = 0 
	cidr_blocks = ["0.0.0.0/0"]
	}

  tags = {
    Name = "${var.project}-${var.environment}-rds-sg"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}
