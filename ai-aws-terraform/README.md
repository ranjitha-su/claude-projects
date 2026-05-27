# AWS Terraform — GitOps Demo

This Terraform project provisions a small AWS environment (VPC, subnets, two Ubuntu EC2 instances: `app-server` and `gitlab-runner`), IAM roles, security groups, and an opinionated GitLab CI pipeline that demonstrates CI/CD for Infrastructure as Code (GitOps).

## Table of Contents
- [AWS Terraform — GitOps Demo](#aws-terraform--gitops-demo)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Architecture](#architecture)
  - [Prerequisites](#prerequisites)
  - [Quick Start](#quick-start)
  - [CI/CD](#cicd)
  - [Project Files](#project-files)
  - [User Prompts (Full History)](#user-prompts-full-history)

## Overview
This repo is a simple, portfolio-ready example showing how to manage AWS infrastructure with Terraform and automate workflows using GitLab CI. It includes:

- Terraform modules for `vpc` and `iam`.
- Two Ubuntu EC2 instances (`app-server`, `gitlab-runner`) with userdata scripts.
- An opinionated `.gitlab-ci.yml` that runs `init`, `validate`, `scan` (Trivy), `plan`, `apply`, and `destroy` stages.

## Architecture

- VPC with a public and private subnet.
- `gitlab-runner` and `app-server` instances (now placed in the private subnet).
- IAM roles so instances can use SSM and pull images from ECR.
- Terraform remote state configured to use an S3 bucket (must be created manually).

## Prerequisites

- Terraform >= 1.0
- AWS credentials configured (environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` or via profile).
- An S3 bucket created manually for Terraform remote state as configured in `backend.tf`.

## Quick Start

Clone the repo and run the normal Terraform workflow locally:

```bash
git clone <repo>
cd aws-terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

CI will also run these steps automatically in GitLab using the included `.gitlab-ci.yml`.

## CI/CD

The pipeline includes the following stages:

- `init` — `terraform init` (caches `.terraform`)
- `validate` — `terraform validate`
- `scan` — `trivy fs` (produces `trivy-report.json`, allowed to fail)
- `plan` — `terraform plan -out=tfplan`
- `apply` — `terraform apply tfplan` (manual)
- `destroy` — `terraform destroy` (manual)

See `.gitlab-ci.yml` for job definitions and artifact wiring.

## Project Files

- `main.tf` — root Terraform configuration that wires modules and resources.
- `variables.tf` / `terraform.tfvars` — variables and sensitive values.
- `modules/` — `vpc` and `iam` modules.
- `scripts/` — userdata scripts for `app_server` and `gitlab_runner`.
- `.gitlab-ci.yml` — GitLab CI pipeline.

## User Prompts (Full History)

This section contains the full iterative prompt history used while building and evolving this Terraform project. It is preserved for traceability and reproducibility.

1. Create aws ec2 instance named gitlab-runner with 20gb storage and t2.large.
	Create aws ec2 instance named app-server with 8gb storage and t2.micro.
	Add terraform and Name tags to both of them.

2. Create iam module. In the module, create gitlab-runner-role and assign aws managed permissions - aws ecr full access and ssm full access to the role. Assign the role to the gitlab-runner instance.

3. Create iam role - app-server-role in the iam module. Assign policy to this role, so the instance that it's assigned to can be managed by an SSM agent. i.e. allow aws ssm session manager access through this role when assigned to an ec2 instance.

4. Add aws ecr full access policy to the app-server-role so it can pull the docker image before running it.

5. Update the aws region to us-west-2

6. Update gitlab-runner to t2.large

7. Create a vpc module. Create a new vpc with cidr block - 10.0.0.0/16, name - main, tags - terraform and name, Create 2 subnet inside the vpc, - priv_main_subnet and pub_main_subnet. private subnet cidr - 10.0.1.0/24 public subnet cidr - 10.0.2.0/24 Create a single nat gateway for instances in the private subnet to reach the internet. Create a internet gateway in the public subnet to allow public requests.

8. Create a security group for app-server ec2 instance and open port 3000 ingress on it for the app. egress allow all ports to the internet.

9. Create user_data for both the ec2 instances.
	for app server, install docker, awscli, add ubuntu and gitlab user to docker group.
	For gitlab-runner instance, install docker, awscli, gitlab runner software and register it with gitlab instance - https://gitlab.com

10. Create a separate script for the userdata in scripts directory and use that file in the user_data

11. Ensure the user_data executes after the instance is fully up (use a systemd service that depends on network-online.target).

12. Update the instances to ubuntu instances and not amazon_linux instances

13. Create terraform.tfvars file with access key id, secret and gitlab-runner registration token. set them all to empty string for now

14. Rename `aws_access_key` and `aws_secret_key` variables to match environment variable names (`aws_access_key_id`, `aws_secret_access_key`) and update provider references.

15. Add the app-server and gitlab-runner to the private subnet.

16. (Not a claude prompt) Create a user on aws using console or awscli - terraform-user and give it aws ec2 full access and aws ssm access, aws iam full access, s3 full access. S3 access is needed to update the terraform state in the s3 bucket. Create access key credentials and set them in terraform.tfvars.

17. Generate a new gitlab registration token. Click on Create new runner and copy the registration token.

18. For the terraform project, save the terraform state in an s3 bucket. First update the tf scripts to create an s3 bucket, and then use this for remote state.

19. Remove the code related to bucket creation as this needs to be done manually before running the tf project.

20. The S3 bucket must be created manually before running terraform init.

21. Add a validate stage to gitlab-ci.yml where we run terraform validate. Also add a tf-scan stage where we use trivy to scan the project. Allow the scan job to fail.

22. Create Trivy scan job to produce `trivy-report.json` and save it as a job artifact (allowed to fail).

23. Add a destroy stage with a tf destroy job where terraform destroy is executed and make it manually triggered.

> Notes: prompts are logged here for reproducibility and collaboration; update this file when you change pipeline behavior or infrastructure topology.


