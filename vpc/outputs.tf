# Outputs

output "vpcId" {
  value = aws_vpc.age_vpc.id
}

output "publicSubnetIds" {
  value = aws_subnet.public_subnets[*].id
}

output "privateSubnetIds" {
  value = aws_subnet.private_subnets[*].id
}