output "cloudfront_dns" {
  description = "DNS endpoint for the private terraform registry."
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}
