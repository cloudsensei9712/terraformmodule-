## Requirements

| Name | Version |
|------|---------|
| sdm | >= 1.0.28 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| sdm | >= 1.0.28 |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| client\_cidr | additional cluster access cidr blocks (e.g. hub, vpn, etc) | `list(string)` | n/a | yes |
| cluster\_dns | cluster dns endpoint IP, 172.20.0.10 coredns or 169.254.20.10 nodelocal | `any` | n/a | yes |
| cluster\_name | n/a | `string` | n/a | yes |
| delete\_detached\_volumes | When true, deletes EBS volumes when EKS instances are terminated (typically as a result of ASG events). | `bool` | `true` | no |
| eks\_version | n/a | `string` | n/a | yes |
| env | app env | `any` | n/a | yes |
| extra\_policies | ARN of extra policies to attach to nodegroups | `list(string)` | `[]` | no |
| internal\_lb\_sg | sg used by internal LBs | `any` | n/a | yes |
| sdm\_resource | When true, enables the creation of an SDM resource for this cluster. | `bool` | `false` | no |
| sdm\_resource\_name | When unset, the name will default to the EKS cluster name, with `eks-` as a prefix. This can be set to give it an explicit name. | `string` | `""` | no |
| ssh\_key\_name | ssh key for instance access | `any` | n/a | yes |
| vpc\_cidr\_blocks | VPC IP blocks | `list(string)` | n/a | yes |
| vpc\_id | ID of hosting VPC | `any` | n/a | yes |
| vpc\_subnet\_ids | vpc subnet IDs | `list(string)` | n/a | yes |
| workloads | n/a | `list(map(string))` | n/a | yes |
| zone\_ids | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| argocd-role-arn | n/a |
| endpoint | n/a |
| irsa-ca-role | n/a |
| irsa-extdns-role | n/a |
| kubeconfig-certificate-authority-data | n/a |
| name | n/a |
| oidc\_id | n/a |
| worker\_sg\_id | n/a |

