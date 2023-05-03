## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow\_lambda\_retrieval | Allow the Lambda service to retrieve images from this repo. | `bool` | `false` | no |
| allowed\_accounts | A list of external AWS accounts that are allowed to read from this repo. | `list(any)` | <pre>[<br>  "802476504392",<br>  "526837709443"<br>]</pre> | no |
| ecr\_account\_id | The AWS account ID for our dedicated ECR account. This account will be given the ability to publish images to the repository. | `string` | `"358789136651"` | no |
| name | Name of the repository | `string` | `""` | no |
| tags | Additional tags (e.g. map('AlexKoin', 'GolmGold')) | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Repository ARN. |
| registry\_id | Registry ID. |
| registry\_url | Repository URL. |
| repository\_name | Repository name. |

