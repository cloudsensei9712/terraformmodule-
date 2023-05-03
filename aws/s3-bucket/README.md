## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acceleration\_status | The s3 bucket acceleration status | `string` | `null` | no |
| allowed\_object\_reader\_arns | [Optional] Use an allowlist of what ARNs are able to read data from this bucket. All other principals (including Admins) will be blocked from reading the data. | `list(string)` | `[]` | no |
| block\_public\_acls | n/a | `string` | `"true"` | no |
| block\_public\_policy | n/a | `string` | `"true"` | no |
| bucket\_name | [Optional] Used to support legacy buckets | `string` | `""` | no |
| cors\_rules | [Optional] json-encoded list of cors rules for the bucket | `string` | `"[]"` | no |
| environment | Name of the environment | `string` | n/a | yes |
| ignore\_public\_acls | n/a | `string` | `"true"` | no |
| kms\_key\_arn | [Optional] Used for SSE-KMS | `string` | `""` | no |
| lifecycle\_policy | [Optional] Used to add a lifecycle policy to objects in an s3 bucket | `string` | `"[]"` | no |
| logging\_bucket\_name | The name of the bucket that stores access logs. | `string` | n/a | yes |
| logging\_prefix | [Optional] The logging prefix. Should be left blank unless you're importing a bucket that uses a non-default value | `string` | `""` | no |
| name | Name of the bucket | `string` | n/a | yes |
| object\_expiry\_days | [Optional] How long to store objects for before they're deleted | `number` | `0` | no |
| object\_lock\_enabled | [Optional] Enable object lock for this bucket | `bool` | `false` | no |
| object\_lock\_rule\_retention\_days | [Optional] Object lock rule's retention period in days. | `string` | `null` | no |
| object\_lock\_rule\_retention\_mode | [Optional] Object lock rule's retention mode to use. Example: GOVERNANCE | `string` | `null` | no |
| policy | [Optional] A json policy for the bucket | `string` | `""` | no |
| restrict\_public\_buckets | n/a | `string` | `"true"` | no |
| tags | [Optional] AWS resource tags to add to the bucket | `map(string)` | `{}` | no |
| versioning\_enabled | Enable versioning. Versioning is a means of keeping multiple variants of an object in the same bucket. | `string` | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | n/a |
| bucket\_regional\_domain\_name | n/a |
| id | n/a |

