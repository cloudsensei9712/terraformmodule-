resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "${var.project}-${var.environment}-${var.table_name}"
  billing_mode   = var.table_billing_mode
  read_capacity  = var.table_read_capacity
  write_capacity = var.table_write_capacity
  hash_key       = var.table_hash_key
  range_key      = var.table_range_key

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }
  attribute {
    name = var.table_hash_key
    type = "S"
  }
  attribute {
    name = var.table_range_key
    type = "S"
  }
  attribute {
    name = "FirstName"
    type = "S"
  }
  attribute {
    name = "LastName"
    type = "S"
  }
  # attribute {
  #   name = "Email"
  #   type = "S"
  # }
  # attribute {
  #   name = "Pronouns"
  #   type = "B"
  # }
  # attribute {
  #   name = "CustomPronouns"
  #   type = "S"
  # }
  # attribute {
  #   name = "PreferredName"
  #   type = "S"
  # }
  # attribute {
  #   name = "RegistrationEmail"
  #   type = "S"
  # }
  # attribute {
  #   name = "Password"
  #   type = "S"
  # }
  # attribute {
  #   name = "ProfilePhoto"
  #   type = "S"
  # }
  # attribute {
  #   name = "HomeBuildCenter"
  #   type = "S"
  # }
  # attribute {
  #   name = "BuildCentersofInterest"
  #   type = "S"
  # }
  # attribute {
  #   name = "SlalomGlobalTeam"
  #   type = "S"
  # }
  # attribute {
  #   name = "JobTitle"
  #   type = "S"
  # }
  # attribute {
  #   name = "Capability"
  #   type = "B"
  # }
  # attribute {
  #   name = "FormerSlalomEmail"
  #   type = "S"
  # }
  #  attribute {
  #   name = "CurrentCompany"
  #   type = "S"
  # }
  # attribute {
  #   name = "CurrentPosition"
  #   type = "S"
  # }
  # attribute {
  #   name = "LinkedInLink"
  #   type = "S"
  # }
  # attribute {
  #   name = "Biography"
  #   type = "S"
  # }
  # attribute {
  #   name = "NotificationEnrollment"
  #   type = "B"
  # }
  # attribute {
  #   name = "ExposeEmailtoOtherAlums"
  #   type = "B"
  # }
  # attribute {
  #   name = "TermsAndConditions"
  #   type = "B"
  # }

  # ttl {
  #   attribute_name = "TimeToExist"
  #   enabled        = false
  # }

   global_secondary_index {
    name               = "Index1"
    hash_key           = "FirstName"
    range_key          =  "LastName"
  
    projection_type    = "INCLUDE"
    non_key_attributes = ["FirstName", "LastName", "Email","Pronouns" ]
  }

   tags = {
     Name = "${var.project}-${var.environment}-${var.table_name}"
    Project = var.project
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}