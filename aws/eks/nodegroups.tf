resource "aws_eks_node_group" "eks_nodegroup" {
  for_each        = { for i in setproduct(var.vpc_subnet_ids, var.workloads) : join("-", compact([i[0], i[1].workload])) => i[1] }
  cluster_name    = var.cluster_name
  node_group_name = join("-", compact([var.cluster_name, each.key]))
  node_role_arn   = aws_iam_role.eks_nodegroup_access.arn
  subnet_ids      = [trimsuffix(each.key, "-${each.value.workload}")]

  launch_template {
    name    = join("-", compact([var.cluster_name, each.value.workload, "lt"]))
    version = aws_launch_template.eks_general[each.value.workload].latest_version
  }

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks_cluster
  ]
  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }
}

resource "aws_iam_role" "eks_nodegroup_access" {
  name_prefix        = join("-", compact([var.cluster_name, "nodeg-access-"]))
  assume_role_policy = data.aws_iam_policy_document.nodegroup_assume_role_policy.json
}

data "aws_iam_policy_document" "nodegroup_assume_role_policy" {
  statement {
    sid = "NodegroupAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_access.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_access.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_access.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_extra_policies" {
  for_each   = toset(var.extra_policies)
  policy_arn = each.key
  role       = aws_iam_role.eks_nodegroup_access.name
}
