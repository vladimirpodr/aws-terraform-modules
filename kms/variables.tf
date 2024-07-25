variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Key
################################################################################

variable "deletion_window_in_days" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30`"
  type        = number
  default     = null
}

variable "description" {
  description = "The description of the key as viewed in AWS console"
  type        = string
  default     = null
}

variable "enable_key_rotation" {
  description = "Specifies whether key rotation is enabled. Defaults to `true`"
  type        = bool
  default     = true
}

variable "key_usage" {
  description = "Specifies the intended use of the key. Valid values: `ENCRYPT_DECRYPT` or `SIGN_VERIFY`. Defaults to `ENCRYPT_DECRYPT`"
  type        = string
  default     = null
}

variable "multi_region" {
  description = "Indicates whether the KMS key is a multi-Region (`true`) or regional (`false`) key. Defaults to `false`"
  type        = bool
  default     = false
}

variable "policy" {
  description = "A valid policy JSON document. Although this is a key policy, not an IAM policy, an `aws_iam_policy_document`, in the form that designates a principal, can be used"
  type        = string
  default     = null
}

variable "enable_default_policy" {
  description = "Specifies whether to enable the default key policy. Defaults to `true`"
  type        = bool
  default     = true
}

variable "key_owners" {
  description = "A list of IAM ARNs for those who will have full key permissions (`kms:*`)"
  type        = list(string)
  default     = []
}

variable "key_administrators" {
  description = "A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators)"
  type        = list(string)
  default     = []
}

variable "key_users" {
  description = "A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users)"
  type        = list(string)
  default     = []
}

variable "key_users_conditions" {
  description = "A list of policy conditions for [key users]"
  default     = []
  type = set(object({
    test     = string
    variable = string
    values   = list(string)
    
  }))
}

variable "key_users_to_decrypt" {
  description = "A list of IAM ARNs for [key users to decrypt](https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_examples_cross.html)"
  type        = list(string)
  default     = []
}

variable "key_users_with_service" {
  description = "A list of IAM ARNs for [key users with service](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration)"
  type        = list(string)
  default     = []
}

variable "key_service_users" {
  description = "A list of AWS services for [key service users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-services.html)"
  type        = list(string)
  default     = []
}

variable "source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
}

variable "override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
}

################################################################################
# Alias
################################################################################

variable "aliases" {
  description = "A list of aliases to create. Note - due to the use of `toset()`, values must be static strings and not computed values"
  type        = list(string)
  default     = []
}