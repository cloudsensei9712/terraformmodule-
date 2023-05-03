variable "project" {
  type        = string
  default     = "foundant"
  description = "Name of the project."
}
variable "env" {
  type        = string
  default     = "dev"
  description = "Name of the Environment."
}
variable "app" {
  type        = string
  default     = "glm"
  description = "Application name."
}

variable "kms_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}
variable "kms_deletion_window_in_days" {
  type        = number
  default     = 30
  description = "Duration in days after which the key is deleted after destruction of the resource."
}
variable "kms_enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled."
}
variable "kms_description" {
  type        = string
  default     = "RDS KMS master key."
  description = "The description of the key as viewed in AWS console."
}
variable "kms_policy" {
  type        = string
  default     = ""
  description = "A valid KMS policy JSON document."
}
variable "tags" {
  type    = map
  default = null
  description = "Additional tags."
}
