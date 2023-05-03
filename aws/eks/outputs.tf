output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "oidc_id" {
  value = replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")
}

output "irsa-extdns-role" {
  value = aws_iam_role.irsa_eks_extdns.arn
}

output "irsa-ca-role" {
  value = aws_iam_role.irsa_eks_ca.arn
}

output "argocd-role-arn" {
  value = aws_iam_role.eks_cluster_argocd.arn
}

output "worker_sg_id" {
  value = aws_security_group.eks_worker_sg.id
}

output "cluster_id" {
  value = aws_eks_cluster.eks_cluster.id
}

output "eks_version" {
  value = aws_eks_cluster.eks_cluster.platform_version
}