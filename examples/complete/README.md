# complete

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_data_bucket"></a> [data\_bucket](#module\_data\_bucket) | ../.. | n/a |
| <a name="module_website_bucket"></a> [website\_bucket](#module\_website\_bucket) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_public_access_block.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_bucket_arn"></a> [data\_bucket\_arn](#output\_data\_bucket\_arn) | ARN of the data bucket |
| <a name="output_data_bucket_domain_name"></a> [data\_bucket\_domain\_name](#output\_data\_bucket\_domain\_name) | Data bucket domain name |
| <a name="output_data_bucket_id"></a> [data\_bucket\_id](#output\_data\_bucket\_id) | The name of the data bucket |
| <a name="output_logs_bucket_id"></a> [logs\_bucket\_id](#output\_logs\_bucket\_id) | The name of the logging bucket |
| <a name="output_website_bucket_arn"></a> [website\_bucket\_arn](#output\_website\_bucket\_arn) | ARN of the website bucket |
| <a name="output_website_bucket_id"></a> [website\_bucket\_id](#output\_website\_bucket\_id) | The name of the website bucket |
| <a name="output_website_domain"></a> [website\_domain](#output\_website\_domain) | Website domain for DNS configuration |
| <a name="output_website_endpoint"></a> [website\_endpoint](#output\_website\_endpoint) | Website endpoint URL |
<!-- END_TF_DOCS -->
