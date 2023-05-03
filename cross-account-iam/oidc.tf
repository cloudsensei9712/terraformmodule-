resource "aws_iam_openid_connect_provider" "oidc_issuer" {
  url             = var.eks_oidc_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  tags = var.tags
}