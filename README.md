# infra-pro
This repository defines the core, shared infrastructure for my ML training and serving platforms on AWS, using Infrastructure as Code (IaC) principles.


## What's Inside

- **Networking:** VPC, private/public subnets, NAT Gateways
- **Compute:** EKS cluster with GPU node groups (g4dn.xlarge)
- **Autoscaling:** Karpenter for dynamic node scaling
- **Security:** IAM roles, OIDC provider for GitHub Actions
- **Storage:** S3 buckets (shared across projects)

## Supports

- **Project 1 (ML Training Platform):** PyTorch training jobs on GPU nodes
- **Project 2 (LLM Serving Platform):** FastAPI inference service

## Tech Stack

- **Infrastructure:** Terraform, AWS (EKS, EC2, S3, VPC, Karpenter)
- **CI/CD:** GithubActions, ARC (Actions Runner Controller), ArgoCD, Argo Rollouts
- **Observability:** Prometheus


