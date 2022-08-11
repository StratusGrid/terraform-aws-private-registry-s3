<!-- BEGIN_TF_DOCS -->
# private-terraform-registry-s3

GitHub: [StratusGrid/private-terraform-registry-s3](https://github.com/StratusGrid/private-terraform-registry-s3)

This module creates a Terraform Provider Registry in AWS S3 which is accessible from specific IP ranges. For details about Terraform provider registries, please see [Provider Registry Protocol](https://www.terraform.io/internals/provider-registry-protocol).
An example is also provided below.

## Example

```hcl
locals {
  versions = [
    {
        version = "0.1.0"
        protocols = ["4.0", "5.1"]
        platforms = [
            {
                os = "darwin"
                arch = "amd64"
            }
        ]
    },
    {
        version = "0.1.0"
        protocols = ["4.0", "5.1"]
        platforms = [
            {
                os = "linux"
                arch = "amd64"
            }
        ]
    }
  ]
  packages = [
    {
      version = "0.1.0"
      pkg_info = {
        protocols = ["4.0", "5.1"]
        os = "darwin"
        arch = "arm64"
        filename = "<provider-filename>.zip"
        download_url = "https://<provider-artifact>.zip"
        shasums_url = "https://<provider-artifact>.SHA256SUMS"
        shasums_signature_url = "https://<provider-artifact>.SHA256SUMS.sig"
        shasum = "<provider-shasum>"
        signing_keys = {
          gpg_public_keys = [{
              key_id = "<gpg-key-id>"
              ascii_armor = <<EOT
-----BEGIN PGP PUBLIC KEY BLOCK-----

<pgp-public-key>
-----END PGP PUBLIC KEY BLOCK-----
EOT
            }]
        }
      }
    },
        {
      version = "0.1.0"
      pkg_info = {
        protocols = ["4.0", "5.1"]
        os = "linux"
        arch = "amd64"
        filename = "<provider-filename>.zip"
        download_url = "https://<provider-artifact>.zip"
        shasums_url = "https://<provider-artifact>.SHA256SUMS"
        shasums_signature_url = "https://<provider-artifact>.SHA256SUMS.sig"
        shasum = "<provider-shasum>"
        signing_keys = {
          gpg_public_keys = [{
              key_id = "<gpg-key-id>"
              ascii_armor = <<EOT
-----BEGIN PGP PUBLIC KEY BLOCK-----

<pgp-public-key>
-----END PGP PUBLIC KEY BLOCK-----
EOT
            }]
        }
      }
    }
  ]
}

module "provider" {
    source = "StratusGrid/private-terraform-registry-s3/aws"
    # source   = "github.com/StratusGrid/private-terraform-registry-s3"
    packages = local.packages
    versions = local.versions
    namespace = "<provider-namespace>"
    allowed_ips = ["<allowed-ips>"]
    type      = "<namespace>"
}
```

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.default_oai](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_kms_key.bucket_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.provider_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.log_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.provider_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_policy.allow_access_from_cf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.log_bucket_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.provider_bucket_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_object.packages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.versions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.well_known](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_waf_ipset.ipset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_ipset) | resource |
| [aws_waf_rule.wafrule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_rule) | resource |
| [aws_waf_web_acl.waf_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/waf_web_acl) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | A list of IP CIDRs that are allowed access to the registry. | `list(any)` | n/a | yes |
| <a name="input_input_tags"></a> [input\_tags](#input\_input\_tags) | Map of tags to apply to resources | `map(string)` | <pre>{<br>  "Developer": "StratusGrid",<br>  "Provisioner": "Terraform"<br>}</pre> | no |
| <a name="input_log_bucket"></a> [log\_bucket](#input\_log\_bucket) | Name of the bucket to create. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The provider namespace. | `string` | n/a | yes |
| <a name="input_packages"></a> [packages](#input\_packages) | List of provider packages. | <pre>list(object({<br>    version = string<br>    pkg_info = object({<br>      protocols             = list(string)<br>      os                    = string<br>      arch                  = string<br>      filename              = string<br>      download_url          = string<br>      shasums_url           = string<br>      shasums_signature_url = string<br>      shasum                = string<br>      signing_keys = object({<br>        gpg_public_keys = list(object({<br>          key_id      = string<br>          ascii_armor = string<br>        }))<br>      })<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_provider_bucket"></a> [provider\_bucket](#input\_provider\_bucket) | Name of the bucket to create. | `string` | `null` | no |
| <a name="input_s3_origin_id"></a> [s3\_origin\_id](#input\_s3\_origin\_id) | The origin ID to use for the registry. | `string` | `"terraform_provider_s3_origin_id"` | no |
| <a name="input_type"></a> [type](#input\_type) | The provider type. | `string` | n/a | yes |
| <a name="input_versions"></a> [versions](#input\_versions) | List of version objects. | <pre>list(object({<br>    version   = string<br>    protocols = list(string)<br>    platforms = list(object({<br>      os   = string<br>      arch = string<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_dns"></a> [cloudfront\_dns](#output\_cloudfront\_dns) | DNS endpoint for the private terraform registry. |

---

Note, manual changes to the README will be overwritten when the documentation is updated. To update the documentation, run `terraform-docs -c .config/.terraform-docs.yml`
<!-- END_TF_DOCS -->