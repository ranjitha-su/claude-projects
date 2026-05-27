variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_access_key_id" {
  description = "AWS access key ID (AWS_ACCESS_KEY_ID)"
  type        = string
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS secret access key (AWS_SECRET_ACCESS_KEY)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "gitlab_runner_registration_token" {
  description = "GitLab Runner registration token for https://gitlab.com"
  type        = string
  default     = ""
  sensitive   = true
}
