variable "name" {
  type        = string
  default     = ""
  description = "Name of the repository"
}

variable "allowed_accounts" {
  type        = list(any)
  default     = ["080572936827", "078152908605", "721961072188", "503627082403", "518419069734", "175307668980", "807691537628", "499054399033", "522323786985", "373383716129", "210069830864", "072181502488", "895601878093", "746954272307", "160569777699", "694593259868", "064491841730", "966597603332"]
  description = "A list of external AWS accounts that are allowed to read from this repo."
}

variable "ecr_account_id" {
  default     = "160569777699"
  description = "The AWS account ID for our dedicated ECR account. This account will be given the ability to publish images to the repository."
}

variable "allow_lambda_retrieval" {
  type        = bool
  default     = false
  description = "Allow the Lambda service to retrieve images from this repo."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map('AlexKoin', 'GolmGold'))"
}
