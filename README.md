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

### 1.3 AWS CLI

Install the AWS Command Line Interface using Homebrew, then verify the installation:

```bash
brew install awscli
aws --version

```
### 1.4 Git

Install Git using Homebrew, then configure your user name and email:

```bash
brew install git
git --version
```
### 1.5 Environment Verification

Verify that all installed binaries are correctly configured and accessible in your system path:

```bash
terraform -version
aws --version
git --version
brew --version

```
## 2. Remote Backend Bootstrap & Infrastructure Provisioning

Before initializing Terraform or deploying resources with a remote state, you must manually bootstrap your state storage and locking infrastructure in AWS to resolve the initial dependency cycle.

### 2.1 Pre-Initialization AWS Setup
1. **Create the S3 State Bucket**: Create a globally unique S3 bucket in your target region (e.g., `us-east-1`) to securely store your `terraform.tfstate` file.
2. **Create the DynamoDB Lock Table**: Create a DynamoDB table named `terraform-lock-table` with a partition key (Primary Key) named **`LockID`** set to type **String** (`S`) to enable state locking and prevent concurrent write collisions.
3. **Authenticate AWS CLI**: Run the configuration wizard in your terminal and enter your IAM user credentials and default region (`us-east-1`):

```bash
aws configure
aws sts get-caller-identity
```
### 2.2 Creating and Populating `main.tf`

Create your primary configuration file directly from your terminal workspace using the touch command:

```bash
touch main.tf
```
Open `main.tf` in your code editor and paste the complete core configuration block:

```hcl
terraform {
  required_version = ">= 1.0.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "shahzads-terraform-sandbox-bucket-2026"
    key            = "environment/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = "us-east-1"
}
```
### Breakdown of the Configuration Blocks

* **`terraform { required_version = ">= 1.0.1" }`**: Enforces that the local Terraform CLI binary must be at least version 1.0.1 or higher to execute the project, preventing compatibility errors.
* **`required_providers` block**: Tells Terraform to download and utilize the official HashiCorp AWS provider plugin, pinning it to version 5.x (`~> 5.0`).
* **`backend "s3" { ... }` block**: Instructs Terraform to migrate and store its state file remotely inside your designated S3 bucket (`shahzads-terraform-sandbox-bucket-2026`) instead of locally, utilizing your DynamoDB table (`terraform-lock-table`) for distributed state locking.
* **`provider "aws" { region = "us-east-1" }` block**: Sets the default target geographical data center region (`us-east-1`) for all AWS resources managed within this configuration.

  ### 2.3 Execution Workflow

Initialize your working directory, validate the syntax, preview the execution plan, and apply the configuration:

```bash
terraform init      # Initializes plugins and migrates state to the remote S3 backend
terraform validate  # Verifies configuration syntax consistency
terraform plan      # Generates an execution preview
terraform apply     # Provisions infrastructure and writes state locks to DynamoDB

```

### 2.4 State Verification

Confirm that your remote backend is actively tracking your infrastructure by running state inspection commands:

```bash
terraform show       # Displays detailed attributes of managed resources
terraform state list # Lists all tracked resources in the workspace

```
### 3. State Management & Backend Configuration

Configure your remote state backend to securely store Terraform state files in an Amazon S3 bucket with DynamoDB state locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "environment/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}

```
### 4. Variables & Parameterization

Define input variables in a `variables.tf` file to parameterize your infrastructure configuration:

```hcl
variable "aws_region" {
  type        = string
  description = "The target AWS region for resource deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name (e.g., dev, prod)"
  default     = "dev"
}

```

### 5. Outputs & Resource References

Define output values in an `outputs.tf` file to expose key resource attributes after deployment:

```hcl
output "vpc_id" {
  description = "The ID of the deployed Virtual Private Cloud"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

```

### 6. Resource Cleanup & Destruction

Tear down your provisioned infrastructure safely when it is no longer needed to avoid ongoing cloud costs:

```bash
terraform destroy

```
### 7. Workflow Summary & Best Practices

Review the core lifecycle commands for managing your Terraform project:

* **`terraform init`**: Initializes the working directory, downloads provider plugins, and sets up the backend.
* **`terraform plan`**: Previews the execution plan to see what infrastructure changes Terraform will make.
* **`terraform apply`**: Executes the actions proposed in the plan to create or update your cloud architecture.
* **`terraform destroy`**: Completely tears down all resources managed by your configuration to prevent unnecessary cloud costs.

### 8. Troubleshooting & Maintenance

Address common issues encountered during Terraform deployments with these standard troubleshooting commands:

* **`terraform refresh`**: Updates the state file against real-world infrastructure without modifying the actual cloud resources.
* **`terraform validate`**: Checks your configuration files for syntax errors and internal consistency independently of any remote state or provider.
* **`terraform fmt`**: Automatically rewrites configuration files to canonical formatting and style standards.

### 9. Project Directory Structure

Organize your files within the workspace following standard conventions for modularity and maintainability:

```text
my-terraform-project/
├── main.tf          # Core resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Exported resource attributes
├── backend.tf       # Remote state configuration
└── terraform.tfvars # Environment-specific variable values

```
### 10. Next Steps & Conclusion

Review your completed infrastructure setup and proceed with building out your specific AWS cloud modules:

* Verify that your remote state backend bucket and DynamoDB locking table are active.
* Begin writing custom resource declarations inside your `main.tf` file.
* Commit your configuration securely to your version control system while ensuring sensitive files like `.tfvars` are excluded via `.gitignore`.
