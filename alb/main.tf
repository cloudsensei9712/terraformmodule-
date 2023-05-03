# This template creates an ALB with all of its components and a security group for it.

# Resources

# Create App target group for alb.
resource "aws_lb_target_group" "age_target_group" {
  name          = "${var.project}-${var.environment}-server-tg"
  target_type   = "ip"
  vpc_id        = var.vpcId
  port          = var.appTargetGroupPort
  protocol      = var.appTargetGroupPort==80 ? "HTTP" : "HTTPS"
  health_check {
    path = "/age-server/public/index.php"
    matcher = 302
  }
}


# Create alb 
resource "aws_lb" "age_alb" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.albSecurityGroupId
  subnets            = var.albSubnetIds
  idle_timeout       = var.albIdleTimeout
}

# Create a https listener for alb which will redirect all the traffic to https port
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.age_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create a https listener for alb which will forward all the traffic to app target group by default
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.age_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.albSSLPolicy
  certificate_arn   = var.albSSLCertificateArn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.age_target_group.arn
  }
}