variable "cluster_name" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "zone_ids" {
  type = list(string)
}

variable "vpc_subnet_ids" {
  description = "vpc subnet IDs"
  type        = list(string)
}

variable "vpc_cidr_blocks" {
  type        = list(string)
  description = "VPC IP blocks"
}

variable "extra_policies" {
  description = "ARN of extra policies to attach to nodegroups"
  type        = list(string)
  default     = []
}

variable "cluster_dns" {
  description = "cluster dns endpoint IP, 172.20.0.10 coredns or 169.254.20.10 nodelocal "
  default     = "169.254.20.10"
}

variable "workloads" {
  type = list(map(string))
}

variable "vpc_id" {
  description = "ID of hosting VPC"
}

variable "ssh_key_name" {
  description = "ssh key for instance access"
}

variable "env" {
  description = "app env"
}

variable "internal_lb_sg" {
  description = "sg used by internal LBs"
}

variable "client_cidr" {
  type        = list(string)
  description = "additional cluster access cidr blocks (e.g. hub, vpn, etc)"
}

variable "sdm_resource" {
  type        = bool
  description = "When true, enables the creation of an SDM resource for this cluster."
  default     = false
}

variable "sdm_resource_name" {
  type        = string
  description = "When unset, the name will default to the EKS cluster name, with `eks-` as a prefix. This can be set to give it an explicit name."
  default     = ""
}

variable "delete_detached_volumes" {
  type        = bool
  description = "When true, deletes EBS volumes when EKS instances are terminated (typically as a result of ASG events)."
  default     = true
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enable/Disable private EP for API server"
  default     = false
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enable/Disable public EP for API server"
  default     = true
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "List of CIDRs that can access the public EP"
  default     = ["0.0.0.0/0"]
}

variable "argocd_aws_account_id" {
  description = "AWS account hosting ArgoCD"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "bottlerocket_admin_source" {
  type        = string
  default     = ""
  description = "The URI of the control container"
}

variable "bottlerocket" {
  type        = bool
  default     = false
  description = "Use Bottlerocket OS, rather than Amazon Linux"
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = "Labels that will be added to the kubernetes node."
}

variable "taints" {
  type        = map(string)
  default     = { }
  description = "taints that will be added to the kubernetes node"
}