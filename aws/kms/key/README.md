## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_policy\_json | Additional policy JSON to merge with the default policies provided by this module. | `string` | `""` | no |
| alias | Optional alias for this key. | `string` | `""` | no |
| allowed\_accounts | n/a | `list(string)` | `[]` | no |
| customer\_master\_key\_spec | Key spec | `string` | `"SYMMETRIC_DEFAULT"` | no |
| description | The description of the key as viewed in AWS console. | `any` | n/a | yes |
| enable\_s3 | When set to true, will allow this key to be used by S3 to use encrypted SQS queues and SNS topics. | `bool` | `false` | no |
| enable\_sns | When set to true, will give allow this key to be used to encrypt SNS topics. | `bool` | `false` | no |
| enable\_sqs | When set to true, will allow this key to be used to encrypt SQS queues. | `bool` | `false` | no |
| key\_usage | KMS key usage | `string` | `"ENCRYPT_DECRYPT"` | no |
| kms\_iam\_policy | Additional policy to merge with the default policies provided by this module. | `string` | `""` | no |
| tags | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| key\_arn | n/a |
| key\_id | n/a |

