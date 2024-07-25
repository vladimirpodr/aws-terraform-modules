################################################################################
# Key
################################################################################

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = aws_kms_key.this.arn
}

output "key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.this.key_id
}

output "key_policy" {
  description = "The IAM resource policy set on the key"
  value       = aws_kms_key.this.policy
}

################################################################################
# Alias
################################################################################

output "aliases" {
  description = "A map of aliases created and their attributes"
  value       = aws_kms_alias.this
}