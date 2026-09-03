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

Ensure your local development environment has the required CLI tools installed before deploying the infrastructure.

### Homebrew

Homebrew is a package manager for macOS and Linux that simplifies installation of development tools and dependencies.

#### macOS

Install Homebrew using the official installer:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
