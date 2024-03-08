output "log_group_name" {
  description = "The name of the CloudWatch log group created for the Lambda function to log to."
  value       = try(aws_cloudwatch_log_group.main[0].name, null)
}
