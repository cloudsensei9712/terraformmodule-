resource "aws_launch_template" "eks_general" {
  for_each = { for i in var.workloads : i.workload => i }

  name = join("-", compact([var.cluster_name, each.value.workload, "lt"]))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  ebs_optimized = true

  image_id = each.value["ami"]

  instance_type = each.value["instance_type"]

  key_name = var.ssh_key_name

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = tomap({ "kubernetes.io/cluster/${var.cluster_name}" = "owned", "Name" = "${var.cluster_name}-${each.value.workload}-node" })
  }
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = lookup(each.value, "storage", null) != null ? each.value["storage"] : 400
      delete_on_termination = var.delete_detached_volumes
      encrypted             = true
    }
  }
  # its not the cleanest but works for now
  user_data = each.value["bottlerocket"] ? base64encode(templatefile("${path.module}/bottlerocket_toml.tpl", {
      cluster_name                 = aws_eks_cluster.eks_cluster.name,
      cluster_endpoint             = aws_eks_cluster.eks_cluster.endpoint,
      cluster_ca_data              = aws_eks_cluster.eks_cluster.certificate_authority[0].data,
      cluster_dns                  = var.cluster_dns,
      node_labels                  = join("\n", [for label, value in merge(local.labels, {env=var.env, workload=each.value["workload"]}) : "\"${label}\" = \"${value}\""]),
      node_taints                  = join("\n", [for taint, value in var.taints : "\"${taint}\" = \"${value}\""]),
      admin_container_enabled      = true,
      admin_container_superpowered = true,
      admin_container_source       = var.bottlerocket_admin_source,
    })) : base64encode(templatefile("${path.module}/ud_bash.tpl", {
      cluster_name                 = aws_eks_cluster.eks_cluster.name,
      cluster_dns                  = var.cluster_dns
      env                          = var.env
      workload                     = each.value["workload"]
    }))

  vpc_security_group_ids = [aws_security_group.eks_worker_sg.id]
}

locals {
  autoscaler_tags      = { "k8s.io/cluster-autoscaler/enabled" = "true", "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned" }
  bottlerocket_tags    = { "Name" = "eks-node-aws_eks_cluster.cluster.name" }
  tags                 = merge(var.tags, { "kubernetes.io/cluster/${var.cluster_name}" = "owned"}, local.autoscaler_tags, local.bottlerocket_tags)
  labels = merge(
    var.labels, 
  )
}
