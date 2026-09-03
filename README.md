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


Terraform CLIInstall the HashiCorp Terraform CLI via Homebrew:Bashbrew tap hashicorp/tap
brew install hashicorp/tap/terraform
AWS CLIInstall the official Amazon Web Services command line tool:Bashbrew install awscli
2. AWS Authentication & Security ConfigurationConfigure your local AWS credentials securely to allow Terraform to communicate with your AWS account.Run the configuration command:Bashaws configure
Verify active identity connection:Bashaws sts get-caller-identity
3. Core Terraform Lifecycle WorkflowExecute these commands sequentially inside your project directory to manage infrastructure:CommandPurposeterraform initInitializes the working directory and downloads required provider plugins.terraform validatePerforms an offline syntax and configuration check on your HCL files.terraform planGenerates an execution preview mapping your configuration against actual AWS resources.terraform applyProvisions or updates the physical cloud infrastructure.terraform destroyTears down all managed infrastructure to prevent idle resource costs.
