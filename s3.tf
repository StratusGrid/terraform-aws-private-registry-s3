resource "aws_s3_bucket" "provider_bucket" {
  bucket = var.provider_bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning {
    enabled = true
  }
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
  }
  tags = local.tags
}

resource "aws_s3_bucket_acl" "provider_bucket_acl" {
  bucket = aws_s3_bucket.provider_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "provider_bucket_block" {
  bucket                  = aws_s3_bucket.provider_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  versioning {
    enabled = true
  }
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
  }
  tags = local.tags
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "log_bucket_block" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "bucket_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_s3_object" "well_known" {
  key          = ".well-known/terraform.json"
  bucket       = aws_s3_bucket.provider_bucket.id
  content_type = "application/json"
  content      = "{\"providers.v1\": \"/v1/providers/\"}"
  tags         = local.tags
}

resource "aws_s3_object" "versions" {
  key          = "v1/providers/${var.namespace}/${var.type}/versions"
  bucket       = aws_s3_bucket.provider_bucket.id
  content_type = "application/json"
  content      = templatefile("${path.module}/templates/versions.json", { versions = var.versions })
  tags         = local.tags
}

resource "aws_s3_object" "packages" {
  for_each = {
    for index, pkg in var.packages :
    join("-", [pkg.pkg_info.os, pkg.pkg_info.arch]) => pkg
  }
  key          = "v1/providers/${var.namespace}/${var.type}/${each.value.version}/download/${each.value.pkg_info.os}/${each.value.pkg_info.arch}"
  bucket       = aws_s3_bucket.provider_bucket.id
  content_type = "application/json"
  content      = jsonencode(each.value.pkg_info)
  tags         = local.tags
}

resource "aws_cloudfront_origin_access_identity" "default_oai" {
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.provider_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.default_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cf" {
  bucket = aws_s3_bucket.provider_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
