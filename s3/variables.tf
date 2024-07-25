variable "name" {
  description = "The name of the bucket. If omitted."
  type        = string
}

variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}

variable "policy" {
  description = "A valid bucket policy JSON document"
  type        = string
  default     = null
}

variable "attach_s3_access_log_delivery_policy" {
  description = "Controls if S3 bucket should have S3 access log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_elb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ELB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_log_delivery_policy" {
  description = "Controls if S3 bucket should have ALB/NLB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_deny_insecure_transport_policy" {
  description = "Controls if S3 bucket should have deny non-SSL transport policy attached"
  type        = bool
  default     = false
}

variable "attach_deny_unencrypted_objects_policy" {
  description = "Controls if S3 bucket should prevent users from uploading unencrypted objects, unless they are using server-side encryption with server-side encryption with AWS KMS–managed keys (SSE-KMS)"
  type        = bool
  default     = false
}

variable "attach_policy_website" {
  description = "A boolean, that enable static web-site hosting."
  type        = bool
  default     = false
}

variable "acl" {
  description = "The canned ACL to apply. Defaults to 'private'"
  type        = string
  default     = "private"
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "(Optional) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default     = {}
}

variable "replication" {
  description = "Map containing cross-region replication configuration."
  type        = map(string)
  default     = {}
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "enable_sse" {
  description = "Whether Amazon S3 should enable server-side encryption for this bucket."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use."
  type        = string
  default     = "aws:kms"
}

variable "sse_kms_bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = null
}

variable "lifecycle_rules" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "logging" {
  description = "Map containing access bucket logging configuration."
  type        = map(string)
  default     = {}
}
