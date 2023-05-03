resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  
  lifecycle {
    prevent_destroy = false
  }
  
  tags = {
    Project = var.project
    Environment = var.environment
    CreatedBy = var.createdBy
  }

}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "s3_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "private"
}

resource "aws_cloudfront_origin_access_identity" "s3_cdn_origin_identity" {
  comment = "S3 Origin Access Identity"
}


resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_cdn_origin_identity.iam_arn ]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [ "${aws_s3_bucket.s3_bucket.arn}/*"]

  }
}



resource "aws_cloudfront_distribution" "s3_cdn_distribution" {

  enabled             = true
  comment             = var.s3_cdn_description
  price_class         = var.cdn_price_class
  default_root_object = var.s3_cdn_root_object
  aliases = [ var.s3_cdn_domain ]
  web_acl_id = var.waf_arn

  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = var.s3_origin_id
      s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.s3_cdn_origin_identity.cloudfront_access_identity_path

      }
    }


  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id
    cache_policy_id = aws_cloudfront_cache_policy.cdn_cache_policy.id
    # forwarded_values {
    #   query_string = false

    #   cookies {
    #     forward = "none"
    #   }
    # }

    viewer_protocol_policy = "redirect-to-https"
    
  }



  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn =  var.cdn_certificate_arn
    ssl_support_method = "sni-only"

  }

//Error Page 
custom_error_response {
    error_code = 403
    response_code = 404
    response_page_path = "/404.html"
  }
  custom_error_response {
    error_code = 404
    response_code = 404
    response_page_path = "/404.html"
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Project = var.project
    Environment = var.environment
    CreatedBy = var.createdBy
  }

}

  resource "aws_cloudfront_cache_policy" "cdn_cache_policy" {
    name        = "${var.project}-${var.environment}-cdn-cahe-policy"
    # Cache Disabled
    default_ttl = 0
    max_ttl     = 0
    min_ttl     = 0
    parameters_in_cache_key_and_forwarded_to_origin {
      cookies_config {
        cookie_behavior = "none"
        
      }
      headers_config {
        header_behavior = "none"
      }
      query_strings_config {
        query_string_behavior = "none"
      }
    }
}