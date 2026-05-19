# infra-pro – AI Platform Infrastructure on AWS EKS

This repository defines a production‑ready infrastructure for AI/ML training on AWS EKS using Infrastructure as Code (IaC). It provides GPU‑accelerated compute with Karpenter autoscaling, full GitOps management via ArgoCD, and a complete observability stack.

---

## 📦 What's Inside

| Component | Technology / Tool |
|-----------|-------------------|
| **Networking** | VPC with private/public subnets, NAT Gateways, DNS hostnames |
| **Compute** | EKS cluster v1.30 + Karpenter (GPU spot autoscaling) |
| **GPU Management** | NVIDIA GPU Operator, EC2NodeClass, NodePool (g4dn.xlarge) |
| **GitOps** | ArgoCD (App‑of‑Apps), multi‑source Helm charts |
| **Observability** | kube‑prometheus‑stack (Prometheus + Grafana + Alertmanager), ServiceMonitor, PrometheusRule |
| **CI/CD Runners** | Actions Runner Controller (ARC) with GPU‑capable runner set |
| **Security** | EKS Pod Identity (for Karpenter), OIDC for GitHub Actions, IAM least privilege |
| **Training Workload** | Simple PyTorch training script that validates GPU, exposes metrics, and uploads results to S3 |

> 💡 The training job is implemented in a [separate repository](https://github.com/ckc9014/training-job) and serves as a proof of concept.

## 🚀 Key Features

- ✅ **Karpenter GPU Autoscaling** – launches GPU spot instances on demand, terminates them when idle (cost‑optimised).
- ✅ **ArgoCD GitOps** – all cluster components are declaratively managed via App‑of‑Apps.
- ✅ **Full Observability** – Prometheus scrapes custom `gpu_active` metrics; Grafana dashboards visualise them.
- ✅ **EKS Pod Identity** – Karpenter controller and training pods obtain IAM roles securely.
- ✅ **Self‑Hosted GitHub Actions Runners** – ARC provides GPU‑capable runners for CI/CD.
- ✅ **Taints & Tolerations** – system nodes (t3.small) host control‑plane components; GPU nodes are tainted to isolate workloads.

## 🧰 One‑time Manual Setup (Required Before First Deployment)

### 1. Create an S3 bucket for Terraform state

Create an S3 bucket (globally unique name, e.g., `my-terraform-state-bucket`) in your AWS account. This bucket will store the Terraform state for both infrastructure and platform layers.

### 2. Set up OIDC for GitHub Actions (critical)

To allow GitHub Actions to assume an AWS IAM role without long‑lived keys, you need:

- An **IAM OIDC provider** for `token.actions.githubusercontent.com`.
- An **IAM role** with a trust policy allowing that provider and a permissions policy (e.g., `AdministratorAccess` – or more restrictive).

### 3. Add GitHub variables and secrets

In your `infra-repo` → **Settings → Secrets and variables → Actions**, add the following:

#### Variables (non‑secret)

| Variable | Example | Purpose |
|----------|---------|---------|
| `AWS_ROLE_ARN` | `arn:aws:iam::123456789012:role/your-github-oidc-role` | The IAM role ARN for GitHub Actions (from step 2) |
| `AWS_REGION` | `eu-west-1` (or `us-east-2`) | AWS region for all resources |
| `TF_STATE_BUCKET` | `my-terraform-state-bucket` | Name of the S3 bucket for Terraform state |

#### Secrets (required for ARC runners)

| Secret | Description | How to obtain |
|--------|-------------|----------------|
| `ARC_APP_ID` | GitHub App ID | From your GitHub App settings |
| `ARC_APP_INSTALLATION_ID` | Installation ID | Found in the URL when you install the app |
| `ARC_APP_PRIVATE_KEY` | Private key (.pem) | Generated in your GitHub App |

> The platform workflow (`apply-platform.yaml`) creates a Kubernetes secret `github-app-auth` using these values.

### 4. Training repository prerequisites

The training job lives in a [separate repo](https://github.com/ckc9014/training-job). Before using it:

- Create an **ECR repository** (e.g., `training-repo`) – can be done via Terraform or manually.
- Create an **S3 bucket** for model outputs (e.g., `training-bucket-...`).
- Add the following **GitHub variables** in the training repo:

| Variable | Example | Purpose |
|----------|---------|---------|
| `AWS_ROLE_ARN` | (same ARN as above) | OIDC role for GitHub Actions |
| `AWS_REGION` | `eu-west-1` | AWS region |
| `ECR_REPOSITORY` | `training-repo` | Name of the ECR repository |
| `MODEL_BUCKET` | `training-bucket-...` | S3 bucket for uploaded results |

---

## 🔧 Deployment Order

The platform is deployed in **three stages** to ensure all dependencies are met.

1. **Infrastructure** – creates VPC, EKS cluster, IAM roles, EBS CSI add‑on, and an **ECR repository** for training images.  
   → Run `apply-infra.yaml` (workflow_dispatch or push to `main` when `terraform/infrastructure/**` changes).

2. **Training image build** – in the [training‑repo](https://github.com/ckc9014/training-job), trigger the `build-and-push.yaml` workflow. This builds the Docker image and pushes it to the ECR repository created in step 1.  
   ⚠️ **Wait for this step to complete** before proceeding. The training Job will fail with `ImagePullBackOff` if the image does not exist.

3. **Platform** – deploys ArgoCD, Karpenter, Prometheus stack, GPU Operator, ARC, and all GitOps manifests (including the training Job).  
   → Run `apply-platform.yaml` **after** infrastructure succeeds **and** the training image is available in ECR.

### Destroy order (reverse)

1. **Platform** – destroy custom resources (manifests) first, then Helm releases (controllers).  
   → Run `destroy-platform.yaml`.
2. **Infrastructure** – destroy VPC, EKS, IAM.  
   → Run `destroy-infra.yaml`.
---

## 🏗 Repository Structure

```text
infra-repo/
├── .github/
│   ├── actions/
│   │   └── setup-terraform-oidc/          # Reusable OIDC + Terraform action
│   └── workflows/
│       ├── terraform-plan.yaml            # Reusable plan workflow
│       ├── terraform-apply.yaml           # Reusable apply workflow
│       ├── determine-environment.yaml
│       ├── apply-infra.yaml               # Infrastructure (VPC+EKS+IAM)
│       ├── apply-platform.yaml            # Platform (ArgoCD, Karpenter, Prometheus, ARC)
│       ├── destroy-infra.yaml
│       └── destroy-platform.yaml
├── terraform/
│   ├── infrastructure/                    # VPC, EKS, IAM, add‑ons
│   │   ├── backend.tf, vpc.tf, eks-cluster.tf, karpenter-iam.tf, etc
│   │   └── envs/{dev,prod}.tfvars
│   └── platform/
│       ├── helm/                          # Helm releases (via terraform helm_release)
│       │   ├── argocd-helm.tf
│       │   ├── karpenter-helm.tf
│       │   ├── values/
│       │   │   ├── argocd/values.yaml
│       │   │   └── karpenter/values.yaml
│       │   └── envs/{dev,prod}.tfvars
│       └── manifests/                     # Kubernetes YAML resources (via kubernetes_manifest)
│           ├── karpenter-crds.tf          # NodePool, EC2NodeClass
│           ├── argocd-apps.tf             # ArgoCD Applications (optional)
│           └── envs/{dev,prod}.tfvars
├── argocd/
│   ├── platform-root.yaml                 # App‑of‑Apps for platform components
│   ├── apps-root.yaml                     # App‑of‑Apps for user workloads
│   ├── applications/                      # User workloads (training-job)
│   ├── monitoring/                        # Custom PrometheusRules, ServiceMonitors (if not in Helm values)
│   └── platform-apps/                     # Child applications (monitoring-stack, gpu-operator, arc, etc.)
│       └── values/                        # Helm values files referenced by ArgoCD
├── karpenter/                             # Templates for NodePool and EC2NodeClass (used by manifests/karpenter-crds.tf)
├── images/                                # Screenshots for README (pods, S3 result, Prometheus alerts, etc.)
└── README.md
```
---

## 🖼️ Screenshots (Proof of Concept)

The `images/` folder contains evidence that the platform works end‑to‑end:

- **`pods-running.png`** – All essential pods (ArgoCD, Karpenter, Prometheus, GPU Operator, ARC) are running.

- **`s3-result.png`** – The training job uploaded `result.txt` to S3, proving GPU execution and storage integration.

- **`prometheus-alerts.png`** – Prometheus UI displays the custom `GPUMissing` alert rule, confirming observability configuration.

- **`node-exporter-metrics.png`** – A node exporter metric (e.g., `node_cpu_seconds_total`) shows Prometheus is actively scraping.

- **`argocd-apps.png`** – ArgoCD applications are synced (with expected `OutOfSync` for completed jobs or dynamic ARC resources).

These screenshots validate the entire pipeline: infrastructure → GPU provisioning → training → monitoring → GitOps.

---

## 📌 Notes

- **OutOfSync in ArgoCD** – Completed Jobs (`training-job`) and dynamic ARC resources (listener, role binding) are expected to be `OutOfSync`. This does not affect functionality.

- **Destroy workflow** – May occasionally hang due to finalizers; the `destroy-platform.yaml` includes a forced cleanup step (`/finalize` API) to handle stuck namespaces.

- **GPU spot quota** – Requires a one‑time request to AWS Service Quotas (`All G and VT Spot Instance Requests`). Without quota, Karpenter cannot launch GPU nodes.

---

## 📄 License
MIT