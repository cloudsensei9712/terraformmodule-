resource "aws_iam_user" "sdm" {
  count = var.sdm_resource ? 1 : 0

  name = "sdm-eks-${aws_eks_cluster.eks_cluster.name}"
  path = "/sdm/eks/"
}

resource "aws_iam_access_key" "sdm" {
  count = var.sdm_resource ? 1 : 0

  user = aws_iam_user.sdm[0].name
}

resource "sdm_resource" "cluster" {
  count = var.sdm_resource ? 1 : 0

  amazon_eks_user_impersonation {
    name                  = coalesce(var.sdm_resource_name, "eks-${aws_eks_cluster.eks_cluster.name}")
    cluster_name          = aws_eks_cluster.eks_cluster.name
    endpoint              = aws_eks_cluster.eks_cluster.endpoint
    certificate_authority = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    region                = data.aws_region.current.name

    access_key        = aws_iam_access_key.sdm[0].id
    secret_access_key = aws_iam_access_key.sdm[0].secret

    healthcheck_namespace = "default"
  }
}
