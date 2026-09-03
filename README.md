# Terraform Infrastructure Playbook

Production-ready Terraform templates, AWS infrastructure modules, and step-by-step CLI workflows designed for rapid deployment, operational standardization, and technical reference.

---

## Architecture Overview

This repository provides modular Infrastructure as Code (IaC) blueprints to provision, manage, and tear down secure cloud environments using Terraform and AWS.

* **Cloud Provider:** Amazon Web Services (AWS) (`us-east-1`)
* **Orchestration Tool:** HashiCorp Terraform
* **State Management:** Local backend (extensible to remote S3/DynamoDB state locking for production)

---

## 1. Prerequisites & Tooling Setup

Before deploying the infrastructure, ensure the following tools are installed and available in your `PATH`.

| Tool | Purpose | Version |
|------|---------|---------|
| Homebrew | Package management | Latest |
| Terraform | Infrastructure as Code | ≥ 5.0 |
| AWS CLI | AWS resource management | Latest |
| Git | Source control | Latest |

### 1.1 Homebrew

Homebrew provides a convenient way to install and manage development dependencies on macOS and Linux.

<details>
<summary>macOS</summary>

Install Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

```

</details>

### 1.2 Terraform CLI

Install the HashiCorp Terraform command line interface using Homebrew, then verify the installation:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform -version

```
