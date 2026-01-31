# FiveXL Terraform Fun Task

This repository contains my solution to the **FiveXL Terraform Fun Task**, demonstrating multiple ways to host a website on AWS using **Terraform**, following production-oriented best practices such as remote state, environment separation, and infrastructure as code.

---

## Overview

The goal of this task is to:
- Explore and implement **multiple AWS website hosting approaches**
- Use **Terraform exclusively** to provision infrastructure
- Support **auto redeployment** on content changes
- Ensure **stable endpoints**
- Demonstrate **multi-account / multi-environment** deployment (dev & prod)

I implemented **Option A (S3 + CloudFront)** fully and structured the codebase to support additional approaches (Option B).

---

## Architecture Options

### Option A — S3 + CloudFront (Implemented)

**Use case:** Static websites (HTML/CSS/JS)

**Why this approach:**
- Very low operational overhead
- Highly scalable and globally distributed (CDN)
- Built-in HTTPS (TLS) via CloudFront
- Cost-effective and production-proven
- Ideal for static content

**Architecture:**
- Private S3 bucket for website assets
- CloudFront distribution with Origin Access Control (OAC)
- Terraform-managed uploads using `aws_s3_object`
- CloudFront HTTPS endpoint as the stable URL

**Key properties:**
- **Stable endpoint:** CloudFront distribution URL
- **Auto redeploy:** Any change to files in `/site` triggers re-upload via Terraform
- **TLS:** Enabled by default with CloudFront

---

### Option B — ECS Fargate + ALB (Planned)

**Use case:** Dynamic websites, SSR apps, APIs

**Why this approach:**
- Supports containerized workloads
- Rolling deployments and scaling
- Suitable for dynamic backends
- Common production setup for modern web apps

**Planned architecture:**
- ECS Fargate service running a containerized web app
- Application Load Balancer (ALB) as a stable endpoint
- Optional HTTPS via ACM
- Redeployments triggered by new container images

---

## Environments & Multi-Account Setup

The same Terraform codebase is deployed into **two separate AWS accounts**:

- **dev** — development environment
- **prod** — production environment

Each environment has:
- Its own AWS account
- Its own Terraform remote state
- Its own CloudFront distribution and S3 bucket

Environment-specific configuration lives in:

infra/envs/dev
infra/envs/prod

Deployment is controlled via AWS CLI profiles:

```bash
AWS_PROFILE=dev
AWS_PROFILE=prod

