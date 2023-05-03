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

variable "bucket_name"{
  type        = string
  default     = "foundant-0089892334"
  description = "S3 bucket name"
}

variable "bucket_versioning"{
  type        = bool
  default     = true
  description = "S3 bucket versioning"

}

variable "s3_origin_id" {
  type = string
  default = "myS3Origin"
}
variable "s3_cdn_description" {
  type = string
  default = "CDN for S3 Hosting"
}
variable "s3_cdn_root_object" {
  type = string
  default = "index.html"
}
variable "s3_cdn_domain" {
  type = string
  default = "abc.com"
  
}
variable "cdn_price_class" {
  type = string
  default = "abc.com"
}

variable "cdn_certificate_arn" {
  type = string
  default = "abc.com"
}
variable "waf_arn" {
   type = string
}