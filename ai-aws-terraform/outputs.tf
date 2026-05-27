output "gitlab_runner_id" {
  description = "ID of the GitLab runner EC2 instance"
  value       = aws_instance.gitlab_runner.id
}

output "gitlab_runner_public_ip" {
  description = "Public IP address of the GitLab runner EC2 instance"
  value       = aws_instance.gitlab_runner.public_ip
}

output "app_server_id" {
  description = "ID of the app-server EC2 instance"
  value       = aws_instance.app_server.id
}

output "app_server_public_ip" {
  description = "Public IP address of the app-server EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "vpc_id" {
  description = "ID of the main VPC"
  value       = module.main_vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.main_vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.main_vpc.private_subnet_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.main_vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.main_vpc.nat_gateway_id
}
