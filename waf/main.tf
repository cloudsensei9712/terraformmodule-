# data "aws_region" "region" {}
# data "aws_caller_identity" "account" {}
resource "aws_wafv2_web_acl" "waf" {
  count       = var.waf_count
  name        = "${var.project}-${var.environment}-${var.waf_name[count.index]}"
  description =  "${var.project}-${var.environment}-${var.waf_name[count.index]} WEB ACL"
  scope       = var.waf_scope[count.index]

  default_action {
    allow {}
  }

  rule {
    name     = "${var.project}-${var.environment}-${var.waf_name[count.index]}-rule"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "CA"]
          }
        }
      }
    }
    

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "${var.project}-${var.environment}-${var.waf_name[count.index]}-metric"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Project = var.project
    Environment = var.environment
    CreatedBy = var.createdBy
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-${var.environment}-${var.waf_name[count.index]}-rule"
    sampled_requests_enabled   = false
  }
}

# resource "aws_wafv2_web_acl_association" "waf_association" {
#   count = var.waf_count
#   resource_arn = var.resource_arn[count.index]
#   web_acl_arn  = "arn:aws:wafv2:${data.aws_region.region.name}:${data.aws_caller_identity.account.id}:regional/webacl/${var.project}-${var.environment}-${var.waf_name[count.index]}/${aws_wafv2_web_acl.waf[count.index].id}"
#  #aws_wafv2_web_acl.waf[count.index].arn
# }