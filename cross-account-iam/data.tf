data "aws_iam_policy_document" "irsa" {
    version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.oidc_issuer.arn
      ]
    }
    condition {
      test = var.kubernetes_namespace == "*" ? "StringLike" : "StringEquals"
      variable = "${aws_iam_openid_connect_provider.oidc_issuer.arn}:sub" 
      values =  concat([
        "system:serviceaccount:${var.kubernetes_namespace}:${var.service_account_name}",
        ], var.additional_oidc_subs
      )
    }
  }
}