output "ad_id" {
  description = "Active directory ID."
  value       = join("", aws_directory_service_directory.ad[*].id)
}
output "ad_dns_ip_addresses" {
  description = "Active directory DNS IP addresses."
  value       = join("", flatten(aws_directory_service_directory.ad[*].dns_ip_addresses))
}
