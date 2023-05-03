resource "aws_cognito_user_pool" "user_pool" {

  count                      = var.user_pool_count
  name                       = "${var.project}-${var.environment}-${var.user_pool_name[count.index]}"
  mfa_configuration          = var.user_pool_mfa_configuration[count.index]
  sms_authentication_message = "Your authentication code is {####}"
  #sms_verification_message   = "Your verification code is {####}"

  account_recovery_setting {
    recovery_mechanism {
      name = "verified_phone_number"
      priority = 1
    }
    recovery_mechanism {
      name = "verified_email"
      priority = 2
    }
  }
  #alias_attributes = ["email", "phone_number"]
  auto_verified_attributes = [ "email" ]
  username_attributes = [ "email", "phone_number" ]
  
  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
    email_message = "Your verification code is {####}"
    sms_message = "Your verification code is {####}"
  }

  software_token_mfa_configuration {
    enabled = true
  }

  email_configuration {
    email_sending_account = var.use_custom_ses[count.index] ? "DEVELOPER" : "COGNITO_DEFAULT"
    source_arn =  var.use_custom_ses[count.index] ? var.ses_endpoint_arn[count.index] : null
  }

  schema {
    name                     = "given_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false  
    required                 = true 
    string_attribute_constraints  {
      min_length = "5"
      max_length = "50"
    }
  }

  schema {
    name                     = "family_name"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  
    required                 = true
    string_attribute_constraints  {
      min_length = "5"
      max_length = "50"
    }
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  
    required                 = true
    string_attribute_constraints  {
      min_length = "5"
      max_length = "50"
    }
  }
  
  

  
  schema {
    name                     = "address"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  
    required                 = true
     string_attribute_constraints  {
      min_length = "5"
      max_length = "100"
    }
  }
  # schema {
  #   name                     = "gender"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true  
  #   required                 = true
  #  string_attribute_constraints  {
  #    min_length = "5"
  #     max_length = "50"
  #   }
  # }
  
  # schema {
  #   name                     = "birthdate"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true  
  #   required                 = true
  #   string_attribute_constraints  {
  #      min_length = "5"
  #     max_length = "50"
  #   }
  # }

  # schema {
  #   name                     = "experience"
  #   attribute_data_type      = "String"
  #   developer_only_attribute = false
  #   mutable                  = true  
  #   required                 = false
  #   string_attribute_constraints  {
  #     min_length = "5"
  #     max_length = "50"
  #   }
  # }
  
  schema {
    name                     = "company"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true  
    required                 = false
    string_attribute_constraints {
      min_length = "5"
      max_length = "50"
    }
  }

   tags = {
    Project = var.project
    Environment = var.environment
    CreatedBy = var.createdBy
  }
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  count = var.user_pool_count
  domain = var.user_pool_domain_name[count.index]
  user_pool_id =  aws_cognito_user_pool.user_pool[count.index].id
  
}

# resource "aws_cognito_identity_provider" "user_pool_provider" {
#   count = var.user_pool_count
#   user_pool_id  = aws_cognito_user_pool.user_pool[count.index].id
#   provider_name = "${var.project}-${var.environment}-${var.user_pool_name[count.index]}-idp"
#   provider_type = "SAML"
#   provider_details = {
#     "MetadataFile": "<?xml version=\"1.0\" encoding=\"utf-8\"?><EntityDescriptor xmlns=\"urn:oasis:names:tc:SAML:2.0:metadata\" ID=\"_123456789\" entityID=\"https://sts.windows.net/abc123456789/\">...</IDPSSODescriptor></EntityDescriptor>"
#   }

# }

resource "aws_cognito_user_pool_client" "user_pool_client" {
  count        = var.user_pool_count
  name = "${var.project}-${var.environment}-${var.user_pool_name[count.index]}-client"
  user_pool_id = aws_cognito_user_pool.user_pool[count.index].id
  callback_urls = ["http://localhost"]
  default_redirect_uri = "http://localhost"
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid"]
  allowed_oauth_flows                  = ["code", "implicit"]
  explicit_auth_flows                  = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  
  supported_identity_providers         = [  "COGNITO"]#, aws_cognito_identity_provider.user_pool_provider[count.index].id ]
}

