data "aws_vpc_endpoint_service" "dynamodb" {
  count   = var.enable_dynamodb_endpoint ? 1 : 0
  service = "dynamodb"
}

data "aws_vpc_endpoint_service" "sns" {
  count   = var.enable_sns_endpoint ? 1 : 0
  service = "sns"
}

data "aws_vpc_endpoint_service" "ses" {
  count   = var.enable_ses_endpoint ? 1 : 0
  service = "email-smtp"
}
############################
# VPC Endpoint for DynamoDB
############################
resource "aws_vpc_endpoint" "dynamodb" {
  count        = var.enable_dynamodb_endpoint ? 1 : 0
  vpc_id       = aws_vpc.vpc.id
  service_name = data.aws_vpc_endpoint_service.dynamodb[count.index].service_name
  tags         = var.tags
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = var.enable_dynamodb_endpoint && length(var.private_subnets_cidr) > 0 && var.enable_private_internet_access ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[count.index].id
  route_table_id  = aws_route_table.vpc_private_rt[count.index].id
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = var.enable_dynamodb_endpoint && length(var.public_subnets_cidr) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.dynamodb[count.index].id
  route_table_id  = aws_route_table.vpc_public_rt.id
}
############################
# VPC Endpoint for SNS
############################

resource "aws_vpc_endpoint" "sns" {
  count             = var.enable_sns_endpoint ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Interface"
  service_name      = data.aws_vpc_endpoint_service.sns[count.index].service_name
  tags              = var.tags
}

resource "aws_vpc_endpoint_route_table_association" "private_sns" {
  count = var.enable_sns_endpoint && length(var.private_subnets_cidr) > 0 && var.enable_private_internet_access ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.sns[count.index].id
  route_table_id  = aws_route_table.vpc_private_rt[count.index].id
}

# resource "aws_vpc_endpoint_route_table_association" "public_sns" {
#   count = var.enable_sns_endpoint && length(var.public_subnets_cidr) > 0 ? 1 : 0

#   vpc_endpoint_id = aws_vpc_endpoint.sns[count.index].id
#   route_table_id  = aws_route_table.vpc_public_rt.id
# }

############################
# VPC Endpoint for SES
############################

resource "aws_vpc_endpoint" "ses" {
  count             = var.enable_ses_endpoint ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Interface"
  service_name      = data.aws_vpc_endpoint_service.ses[count.index].service_name
  tags              = var.tags
}

resource "aws_vpc_endpoint_route_table_association" "private_ses" {
  count = var.enable_ses_endpoint && length(var.private_subnets_cidr) > 0 && var.enable_private_internet_access ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.ses[count.index].id
  route_table_id  = aws_route_table.vpc_private_rt[count.index].id
}

# resource "aws_vpc_endpoint_route_table_association" "public_ses" {
#   count = var.enable_ses_endpoint && length(var.public_subnets_cidr) > 0 ? 1 : 0

#   vpc_endpoint_id = aws_vpc_endpoint.ses[count.index].id
#   route_table_id  = aws_route_table.vpc_public_rt.id
# }