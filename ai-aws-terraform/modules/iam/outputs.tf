output "role_arn" {
  description = "ARN of the IAM role created for GitLab runner"
  value       = aws_iam_role.this.arn
}

output "instance_profile_name" {
  description = "Instance profile name for the GitLab runner EC2 instance"
  value       = aws_iam_instance_profile.this.name
}
