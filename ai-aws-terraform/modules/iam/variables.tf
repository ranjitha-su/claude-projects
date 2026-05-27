variable "role_name" {
  description = "IAM role name for the EC2 instance"
  type        = string
  default     = "gitlab-runner-role"
}

variable "instance_profile_name" {
  description = "IAM instance profile name for the EC2 instance"
  type        = string
  default     = "gitlab-runner-instance-profile"
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the IAM role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  ]
}

variable "tags" {
  description = "Tags to apply to the IAM role and instance profile"
  type        = map(string)
  default     = {}
}
