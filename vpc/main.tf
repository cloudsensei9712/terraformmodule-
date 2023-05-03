# VPC with  public and  private subnets and a security Group

# Create the VPC
resource "aws_vpc" "age_vpc"  {
  cidr_block           = var.vpcCIDR
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
	tags = {
    Name = "${var.project}-${var.environment}-vpc"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

# Create the Public Subnets
resource "aws_subnet" "public_subnets" {
  count = var.publicSubnetCount
  vpc_id                  = aws_vpc.age_vpc.id
  cidr_block              = var.publicSubnetsCIDR[count.index]
  map_public_ip_on_launch = var.mapPublicIP 
  availability_zone       = var.vpcAZs[count.index]
  tags = {
    Name = "${var.project}-${var.environment}-vpc-public-subnet-${count.index+1}"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

# Create the Private Subnets
resource "aws_subnet" "private_subnets" {
  count = var.privateSubnetCount
  vpc_id                  = aws_vpc.age_vpc.id
  cidr_block              = var.privateSubnetsCIDR[count.index]
  map_public_ip_on_launch = !var.mapPublicIP
  availability_zone       = var.vpcAZs[count.index]
  tags = {
    Name = "${var.project}-${var.environment}-vpc-private-subnet-${count.index+1}"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.age_vpc.id
  tags = {
      Name = "${var.project}-${var.environment}-vpc-internet-gateway"
      Environment = var.environment
      CreatedBy = var.createdBy
    }
}

# Create the Public Route Table
resource "aws_route_table" "vpc_public_rt" {
    vpc_id = aws_vpc.age_vpc.id
  tags = {
      Name = "${var.project}-${var.environment}-vpc-public-route-table"
      Environment = var.environment
      CreatedBy = var.createdBy
    }
}

# Create the Internet Access with Public Subnets
resource "aws_route" "vpc_public_internet_access" {
  route_table_id        = aws_route_table.vpc_public_rt.id
  destination_cidr_block = var.destinationCIDR
  gateway_id             = aws_internet_gateway.vpc_igw.id
} 

# Associate the Route Table with the Public Subnets
resource "aws_route_table_association" "vpc_public_associations" {
    count = var.publicSubnetCount
    subnet_id      = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.vpc_public_rt.id
}

#Create EIP required for Private Internet Access
resource "aws_eip" "vpc_NGW_EIP" {
  count = var.enablePrivateInternetAccess ? var.privateSubnetCount : 0
  vpc              = true
}

# Create the NAT Gateway to enable internet access for private Subnets
resource "aws_nat_gateway" "vpc_NGW" {
  count = var.enablePrivateInternetAccess ? var.privateSubnetCount : 0
  allocation_id = aws_eip.vpc_NGW_EIP[count.index].id
  subnet_id  = aws_subnet.public_subnets[count.index].id
  tags = {
    Name = "${var.project}-${var.environment}-vpc-nat-gateway"
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

# Create the Private Route Table
resource "aws_route_table" "vpc_private_rt" {
  count = var.enablePrivateInternetAccess ? 1 : 0
    vpc_id = aws_vpc.age_vpc.id
  tags = {
      Name = "${var.project}-${var.environment}-vpc-private-route-table"
      Environment = var.environment
      CreatedBy = var.createdBy
    }
}

# Create the Internet Access with Private Subnets
resource "aws_route" "vpc_private_internet_access" {
  count = var.enablePrivateInternetAccess ? 1 : 0
  route_table_id        = aws_route_table.vpc_private_rt[0].id
  destination_cidr_block = var.destinationCIDR
  nat_gateway_id             = aws_nat_gateway.vpc_NGW[count.index].id
} 

# Associate the Route Table with the Public Subnets
resource "aws_route_table_association" "vpc_private_associations" {
    count = var.enablePrivateInternetAccess ? var.privateSubnetCount : 0
    subnet_id      = aws_subnet.private_subnets[count.index].id
    route_table_id = aws_route_table.vpc_private_rt[0].id
}



data "aws_vpc_endpoint_service" "dynamodb" {
  count = "${var.enableDynamodbEndpoint ? 1 : 0}"
  service = "dynamodb"
}

data "aws_vpc_endpoint_service" "sns" {
  count = "${var.enableSnsEndpoint ? 1 : 0}"
  service = "sns"
}

data "aws_vpc_endpoint_service" "ses" {
  count = "${var.enableSesEndpoint ? 1 : 0}"
  service = "email-smtp"
}
############################
# VPC Endpoint for DynamoDB
############################
resource "aws_vpc_endpoint" "dynamodb" {
  count = "${var.enableDynamodbEndpoint ? 1 : 0}"
  vpc_id       = aws_vpc.age_vpc.id
  service_name = "${data.aws_vpc_endpoint_service.dynamodb[count.index].service_name}"
  tags = {
      Name = "${var.project}-${var.environment}-dynamodb-endpoint"
      Environment = var.environment
      CreatedBy = var.createdBy
    }
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = "${var.enableDynamodbEndpoint && var.privateSubnetCount > 0 && var.enablePrivateInternetAccess ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb[count.index].id}"
  route_table_id  = "${aws_route_table.vpc_private_rt[count.index].id}"
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = "${var.enableDynamodbEndpoint && var.publicSubnetCount > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb[count.index].id}"
  route_table_id  = "${aws_route_table.vpc_public_rt.id}"
}
############################
# VPC Endpoint for SNS
############################

resource "aws_vpc_endpoint" "sns" {
  count = "${var.enableSnsEndpoint ? 1 : 0}"
  vpc_id       = aws_vpc.age_vpc.id
  vpc_endpoint_type = "Interface"
  service_name = "${data.aws_vpc_endpoint_service.sns[count.index].service_name}"
  tags = {
      Name = "${var.project}-${var.environment}-sns-endpoint"
      Environment = var.environment
      CreatedBy = var.createdBy
    }
}

# resource "aws_vpc_endpoint_route_table_association" "private_sns" {
#   count = "${var.enableSnsEndpoint && var.privateSubnetCount > 0 && var.enablePrivateInternetAccess ? 1 : 0}"

#   vpc_endpoint_id = "${aws_vpc_endpoint.sns[count.index].id}"
#   route_table_id  = "${aws_route_table.vpc_private_rt[count.index].id}"
# }

# resource "aws_vpc_endpoint_route_table_association" "public_sns" {
#   count = "${var.enableSnsEndpoint && var.publicSubnetCount > 0 ? 1 : 0}"

#   vpc_endpoint_id = "${aws_vpc_endpoint.sns[count.index].id}"
#   route_table_id  = "${aws_route_table.vpc_public_rt.id}"
# }

############################
# VPC Endpoint for SES
############################

resource "aws_vpc_endpoint" "ses" {
  count = "${var.enableSesEndpoint ? 1 : 0}"
  vpc_id       = aws_vpc.age_vpc.id
  vpc_endpoint_type = "Interface"
  service_name = "${data.aws_vpc_endpoint_service.ses[count.index].service_name}"
  tags = {
      Name = "${var.project}-${var.environment}-ses-endpoint"
      Environment = var.environment
      CreatedBy = var.createdBy
    }
}

# resource "aws_vpc_endpoint_route_table_association" "private_ses" {
#   count = "${var.enableSesEndpoint && var.privateSubnetCount > 0 && var.enablePrivateInternetAccess ? 1 : 0}"

#   vpc_endpoint_id = "${aws_vpc_endpoint.ses[count.index].id}"
#   route_table_id  = "${aws_route_table.vpc_private_rt[count.index].id}"
# }

# resource "aws_vpc_endpoint_route_table_association" "public_ses" {
#   count = "${var.enableSesEndpoint && var.publicSubnetCount > 0 ? 1 : 0}"

#   vpc_endpoint_id = "${aws_vpc_endpoint.ses[count.index].id}"
#   route_table_id  = "${aws_route_table.vpc_public_rt.id}"
# }
