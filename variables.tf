# Required
variable "versions" {
  description = "List of version objects."
  type = list(object({
    version   = string
    protocols = list(string)
    platforms = list(object({
      os   = string
      arch = string
    }))
  }))

}

variable "packages" {
  description = "List of provider packages."
  type = list(object({
    version = string
    pkg_info = object({
      protocols             = list(string)
      os                    = string
      arch                  = string
      filename              = string
      download_url          = string
      shasums_url           = string
      shasums_signature_url = string
      shasum                = string
      signing_keys = object({
        gpg_public_keys = list(object({
          key_id      = string
          ascii_armor = string
        }))
      })
    })
  }))
}

variable "namespace" {
  description = "The provider namespace."
  type        = string
}

variable "type" {
  description = "The provider type."
  type        = string
}

variable "allowed_ips" {
  description = "A list of IP CIDRs that are allowed access to the registry."
  type        = list(any)
}

# Optional
variable "provider_bucket" {
  description = "Name of the bucket to create."
  type        = string
  default     = null
}

variable "log_bucket" {
  description = "Name of the bucket to create."
  type        = string
  default     = null
}

variable "s3_origin_id" {
  description = "The origin ID to use for the registry."
  type        = string
  default     = "terraform_provider_s3_origin_id"
}

variable "input_tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Developer   = "StratusGrid"
    Provisioner = "Terraform"
  }
}
