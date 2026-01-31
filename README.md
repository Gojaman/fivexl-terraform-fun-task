# FiveXL Terraform Fun Task

This repository contains my solution to the FiveXL Terraform Fun Task, demonstrating multiple ways to host a website on AWS using Terraform, following production-oriented best practices such as remote state, environment separation, and infrastructure as code.

## Overview

The goal of this task is to:
* Explore and implement multiple AWS website hosting approaches
* Use Terraform exclusively to provision infrastructure
* Support auto redeployment on content changes
* Ensure stable endpoints
* Demonstrate multi-account / multi-environment deployment (dev & prod)

I implemented Option A (S3 + CloudFront) fully and structured the codebase to support additional approaches (Option B).

## Architecture Options

### Option A — S3 + CloudFront (Implemented)

**Use case:** Static websites (HTML/CSS/JS)

**Why this approach:**
* Very low operational overhead
* Highly scalable and globally distributed (CDN)
* Built-in HTTPS (TLS) via CloudFront
* Cost-effective and production-proven
* Ideal for static content

**Architecture:**
* Private S3 bucket for website assets
* CloudFront distribution with Origin Access Control (OAC)
* Terraform-managed uploads using `aws_s3_object`
* CloudFront HTTPS endpoint as the stable URL

**Key properties:**
* Stable endpoint: CloudFront distribution URL
* Auto redeploy: Any change to files in `/site` triggers re-upload via Terraform
* TLS: Enabled by default with CloudFront

### Option B — ECS Fargate + ALB (Planned)

**Use case:** Dynamic websites, SSR apps, APIs

**Why this approach:**
* Supports containerized workloads
* Rolling deployments and scaling
* Suitable for dynamic backends
* Common production setup for modern web apps

**Planned architecture:**
* ECS Fargate service running a containerized web application
* Application Load Balancer (ALB) as a stable endpoint
* Optional HTTPS via ACM
* Redeployments triggered by new container images

## Environments & Multi-Account Setup

The same Terraform codebase is deployed into two separate AWS accounts:
* `dev` — development environment
* `prod` — production environment

Each environment has:
* Its own AWS account
* Its own Terraform remote state
* Its own CloudFront distribution and S3 bucket

Environment-specific configuration lives in:
* `infra/envs/dev`
* `infra/envs/prod`

Deployment is controlled via AWS CLI profiles: `AWS_PROFILE=dev` or `AWS_PROFILE=prod`

## Terraform Remote State

Remote state is managed using S3 for state storage and DynamoDB for state locking. State backends are bootstrapped separately per account using `infra/bootstrap`. This ensures safe concurrent Terraform usage, clear separation between environments, and production-ready state management.

## Repository Structure
```
site/                      # Static website files
infra/
  bootstrap/               # Remote state bootstrap (S3 + DynamoDB)
  modules/
    site_s3_cf/            # S3 + CloudFront module
    site_ecs_alb/          # ECS + ALB module (planned)
  envs/
    dev/                   # Dev environment
    prod/                  # Prod environment
.github/workflows/         # CI (optional)
```

## How to Deploy

### 1) Bootstrap remote state (per account)
```
cd infra/bootstrap
export AWS_PROFILE=dev   # or prod
terraform apply -auto-approve -var="env=dev"   # or env=prod
```

### 2) Deploy an environment
```
cd infra/envs/dev         # or prod
export AWS_PROFILE=dev
terraform init -backend-config=backend.hcl
terraform apply -auto-approve
```

## Auto Redeployment

Updating any file in `/site` and re-running Terraform automatically redeploys the website.

Example:
```
echo "<!-- update -->" >> site/index.html
terraform apply -auto-approve
```

The CloudFront endpoint remains stable.

## Results / Endpoints

### DEV account
- **Option A (S3 + CloudFront):** https://d3c95ggevdn3cr.cloudfront.net  
- **Option B (EC2 + ALB):** http://fivexl-fun-task-dev-ec2-alb-923249392.us-east-1.elb.amazonaws.com  

### PROD account
- **Option A (S3 + CloudFront):** https://d2xbyceaz6woe.cloudfront.net  
- **Option B (EC2 + ALB):** http://fivexl-fun-task-prod-ec2-alb-861835306.us-east-1.elb.amazonaws.com  

### Redeploy behavior
- **Option A:** updating files in `/site` → `terraform apply` uploads new objects to S3; CloudFront URL stays stable.  
- **Option B:** updating files in `/site` → `terraform apply` updates user-data/site hash and replaces the instance if needed; ALB DNS name stays stable.


## Notes

- Root AWS users are used **only** for account creation and MFA setup.
- All infrastructure provisioning is performed using IAM users and Terraform.
- The setup mirrors real-world AWS Organizations and multi-account patterns.

## Author

Nick Gojamanov

