data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.vpc_subnet_ids
    #disable pub api ep, internal only
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
  }

  version = var.eks_version

  tags = {}

  encryption_config {
    provider {
      key_arn = module.eks_cmk.key_arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_cloudwatch_log_group.eks_cluster,
  ]
}

module "eks_cmk" {
  source = "../kms/key"

  alias       = "alias/eks-cms-key-${var.cluster_name}"
  description = "EKS CMK for ${var.cluster_name}"
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
}

# security group for cluster and rule attachments
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS control plane SG for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name      = "${var.cluster_name}-cluster-sg"
    CreatedBy = "Terraform"
    app       = "eks"
    region    = data.aws_region.current.name
  }
}

resource "aws_security_group_rule" "eks_client_access" {
  description       = "Allow access to kubernetes api ep"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.client_cidr
  security_group_id = aws_security_group.eks_cluster_sg.id
}

resource "aws_security_group_rule" "eks_private_https" {
  description       = "Allow to access kubernetes"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.vpc_cidr_blocks
  security_group_id = aws_security_group.eks_cluster_sg.id
}

resource "aws_security_group_rule" "eks_cluster_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_worker_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id
}

resource "aws_security_group_rule" "eks_cluster_dd_ca_metrics_https" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_worker_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id
}

resource "aws_security_group_rule" "eks_cluster_allout" {
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.eks_cluster_sg.id
}

# security group for nodegroups and rule attachments
resource "aws_security_group" "eks_worker_sg" {
  name        = "${var.cluster_name}-worker-sg"
  description = "EKS nodegroup SG for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name                                        = "${var.cluster_name}-worker-sg"
    CreatedBy                                   = "Terraform"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    app                                         = "eks"
    region                                      = data.aws_region.current.name
  }
}

resource "aws_security_group_rule" "eks_worker_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_worker_sg.id
}

resource "aws_security_group_rule" "eks_dd_ca_metrics_https" {
  type                     = "ingress"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_worker_sg.id
}

resource "aws_security_group_rule" "eks_worker_internal_lb" {
  description              = "Allow internal LBs to forward traffic to worker nodes"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = var.internal_lb_sg
  security_group_id        = aws_security_group.eks_worker_sg.id
}

resource "aws_security_group_rule" "eks_worker_serviceports" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_worker_sg.id
}

resource "aws_security_group_rule" "eks_worker_nodeports" {
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "-1"

  source_security_group_id = aws_security_group.eks_worker_sg.id
  security_group_id        = aws_security_group.eks_worker_sg.id
}

resource "aws_security_group_rule" "eks_worker_lbc_access" {
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "-1"

  source_security_group_id = aws_security_group.eks_lb_sg.id
  security_group_id        = aws_security_group.eks_worker_sg.id
}

resource "aws_security_group_rule" "eks_tgb_access" {
  description       = "Allow to target group bindings to access ENIs"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = var.vpc_cidr_blocks
  security_group_id = aws_security_group.eks_worker_sg.id
}

resource "aws_security_group_rule" "eks_worker_allout" {
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.eks_worker_sg.id
}

# Ensure that we allow for Path MTU Discovery.
#
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/network_mtu.html#path_mtu_discovery
resource "aws_security_group_rule" "icmp" {
  description       = "ICMP all"
  type              = "ingress"
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = -1
  to_port           = -1
  security_group_id = aws_security_group.eks_worker_sg.id
}

# security group for lbs
resource "aws_security_group" "eks_lb_sg" {
  name        = "${var.cluster_name}-lb-sg"
  description = "LB SG for ${var.cluster_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name                                        = "${var.cluster_name}-lb-sg"
    CreatedBy                                   = "Terraform"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    app                                         = "eks"
    region                                      = data.aws_region.current.name
  }
}

resource "aws_security_group_rule" "eks_lb_http_access" {
  description       = "Allow access to http"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.vpc_cidr_blocks
  security_group_id = aws_security_group.eks_lb_sg.id
}

resource "aws_security_group_rule" "eks_lb_https_access" {
  description       = "Allow access to https"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = concat(var.vpc_cidr_blocks, ["0.0.0.0/0"])
  security_group_id = aws_security_group.eks_lb_sg.id
}

resource "aws_security_group_rule" "eks_lb_all_out" {
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.eks_lb_sg.id
}

data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

# argocd role
resource "aws_iam_role" "eks_cluster_argocd" {
  name               = join("-", compact(["eks", var.cluster_name, "argocd"]))
  assume_role_policy = data.aws_iam_policy_document.cluster_argocd_assume_role_policy.json
}

data "aws_iam_policy_document" "cluster_argocd_assume_role_policy" {
  statement {
    sid = "ArgoCDClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.argocd_aws_account_id}:role/irsa-argocd"]
    }
  }
}

# cluster role
resource "aws_iam_role" "eks_cluster" {
  name_prefix        = join("-", compact(["eks", var.cluster_name, "control-"]))
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AWSCertificateManagerFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}

# external dns role
resource "aws_iam_role" "irsa_eks_extdns" {
  name               = "irsa-eks-extdns-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.extdns_assume_role_policy.json
}

data "aws_iam_policy_document" "extdns_assume_role_policy" {
  statement {
    sid = "IRSAExtDnsAssumeRole"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-dns:external-dns"]
    }
  }
}

resource "aws_iam_policy" "irsa_extdns" {
  name_prefix = "irsa-eks-extdns-"
  policy      = templatefile("${path.module}/r53policy.tpl", { r53zones = join(",", var.zone_ids) })
}

resource "aws_iam_role_policy_attachment" "irsa_extdns" {
  role       = aws_iam_role.irsa_eks_extdns.name
  policy_arn = aws_iam_policy.irsa_extdns.arn
}

# cluster autoscaler role
resource "aws_iam_role" "irsa_eks_ca" {
  name               = "irsa-eks-ca-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.ca_assume_role_policy.json
}

data "aws_iam_policy_document" "ca_assume_role_policy" {
  statement {
    sid = "IRSAClusterAutoscalerAssumeRole"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_policy" "irsa_ca" {
  name_prefix = "irsa-eks-ca-"
  policy      = data.aws_iam_policy_document.irsa_ca.json
}

data "aws_iam_policy_document" "irsa_ca" {
  statement {
    sid = "IRSACAPolicy"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "ec2:DescribeLaunchTemplateVersions",
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }

  statement {

    actions = [
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]

    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/eks:cluster-name"
      values   = [var.cluster_name]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "irsa_ca" {
  role       = aws_iam_role.irsa_eks_ca.name
  policy_arn = aws_iam_policy.irsa_ca.arn
}

# cert-manager role
resource "aws_iam_role" "irsa_eks_cm" {
  name               = "irsa-eks-cm-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.cm_assume_role_policy.json
}

data "aws_iam_policy_document" "cm_assume_role_policy" {
  statement {
    sid = "IRSACertMnagerAssumeRole"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:cert-manager:eks-${var.cluster_name}-cert-manager"]
    }
  }
}

resource "aws_iam_policy" "irsa_cm" {
  name_prefix = "irsa-eks-cm-"
  policy      = templatefile("${path.module}/r53policy-cm.tpl", { r53zones = join(",", var.zone_ids) })
}

resource "aws_iam_role_policy_attachment" "irsa_cm" {
  role       = aws_iam_role.irsa_eks_cm.name
  policy_arn = aws_iam_policy.irsa_cm.arn
}

#cloudwatch stuff
#disabled for now
#resource "aws_cloudwatch_log_subscription_filter" "eks-log-forwarder" {
#  name            = "eks-log-forwarder-${var.cluster_name}"
#  log_group_name  = "/aws/eks/${var.cluster_name}/cluster"
#  destination_arn = "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:datadog-forwarder"
#  filter_pattern  = ""
#}
