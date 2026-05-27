terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  access_key = var.aws_access_key_id != "" ? var.aws_access_key_id : null
  secret_key = var.aws_secret_access_key != "" ? var.aws_secret_access_key : null
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

module "main_vpc" {
  source = "./modules/vpc"

  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "main"
  public_subnet_cidr  = "10.0.2.0/24"
  private_subnet_cidr = "10.0.1.0/24"
  tags = {
    Name      = "main"
    Terraform = "true"
  }
}

module "gitlab_runner_iam" {
  source = "./modules/iam"

  role_name             = "gitlab-runner-role"
  instance_profile_name = "gitlab-runner-instance-profile"
  tags = {
    Name      = "gitlab-runner-role"
    Terraform = "true"
  }
}

resource "aws_instance" "gitlab_runner" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t2.large"
  subnet_id            = module.main_vpc.private_subnet_id
  iam_instance_profile = module.gitlab_runner_iam.instance_profile_name

  user_data = templatefile("${path.module}/scripts/gitlab_runner_userdata.sh.tpl", {
    token = var.gitlab_runner_registration_token
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name      = "gitlab-runner"
    Terraform = "true"
  }
}

module "app_server_iam" {
  source = "./modules/iam"

  role_name             = "app-server-role"
  instance_profile_name = "app-server-instance-profile"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]
  tags = {
    Name      = "app-server-role"
    Terraform = "true"
  }
}

resource "aws_security_group" "app_server" {
  name   = "app-server-sg"
  vpc_id = module.main_vpc.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "app-server-sg"
    Terraform = "true"
  }
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = module.main_vpc.private_subnet_id
  vpc_security_group_ids = [aws_security_group.app_server.id]
  iam_instance_profile   = module.app_server_iam.instance_profile_name

  user_data = file("${path.module}/scripts/app_server_userdata.sh")

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name      = "app-server"
    Terraform = "true"
  }
}
