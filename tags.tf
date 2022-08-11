locals {
  tags = merge(var.input_tags, {
    "ModuleSourceRepo" = "github.com/StratusGrid/private-terraform-registry-s3"
  })
}
