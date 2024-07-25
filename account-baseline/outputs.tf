output "lb_access_logs_s3_bucket_id" {
  value = join("", module.lb_access_logs_s3_bucket.*.bucket_id)
}
