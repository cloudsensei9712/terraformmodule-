variable "zone_id" {
  type        = string
  default     = ""
  description = "Hosted zone ID."
}

variable "name" {
  type        = string
  default     = ""
  description = "Hosted zone name."
}

variable "alb_dns_name" {
  type        = string
  default     = ""
  description = "ALB DNS name."
}

variable "alb_zone_id" {
  type        = string
  default     = ""
  description = "ALB zone id."
}