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

### 2.5 Anatomy of a Terraform Resource Block

To build any cloud infrastructure resource in AWS using Terraform, you use a standardized **resource block** structure. 

#### General Syntax Structure

```hcl
resource "provider_resource_type" "resource_local_name" {
  argument_name = "argument_value"
  argument_name = "argument_value"
}

```
### Component Breakdown

* **`resource`**: The mandatory keyword telling Terraform you want to manage a cloud infrastructure asset.
* **`provider_resource_type`**: The specific type of resource provided by the cloud vendor (e.g., `aws_s3_bucket`, `aws_instance`, `aws_dynamodb_table`). The prefix (`aws_`) corresponds to your AWS provider.
* **`resource_local_name`**: A unique label you choose yourself. It is used inside your Terraform project to reference this specific resource from other blocks, variables, or outputs (e.g., `aws_s3_bucket.test_bucket.id`).
* **Arguments (`{ ... }`)**: The configuration parameters defined by AWS for that resource. Some arguments are required (like naming a bucket), while others are optional.

### Practical Resource Examples

#### 1. Amazon S3 Bucket
```hcl
resource "aws_s3_bucket" "test_bucket" {
  bucket = "shahzad-terraform-resource-test-2026"
}
```
#### 2. Amazon EC2 Instance
```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```
#### 3. Amazon DynamoDB Table
```hcl
resource "aws_dynamodb_table" "app_locks" {
  name         = "app-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```
#### 4. Amazon VPC (Virtual Private Cloud)
```hcl
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "production-vpc"
  }
}
```

#### 5. AWS Subnet
```hcl
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet-1"
  }
}
```
#### 6. AWS Security Group
```hcl
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow inbound HTTP and SSH traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
#### 7. AWS IAM User
```hcl
resource "aws_iam_user" "ci_cd_user" {
  name = "deployment-automation-user"
}
```

#### 8. Amazon SNS Topic (Simple Notification Service)
```hcl
resource "aws_sns_topic" "alerts" {
  name = "infrastructure-alerts-topic"
}

```


#### 9. AWS Lambda Function
```hcl
resource "aws_lambda_function" "my_lambda" {
  filename      = "lambda_payload.zip"
  function_name = "my_sample_lambda"
  role          = "arn:aws:iam::123456789012:role/lambda-execution-role"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
}

```

#### 10. Amazon SQS Queue (Simple Queue Service)
```hcl
resource "aws_sqs_queue" "my_queue" {
  name                      = "my-app-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
}

```
### 2.5 Anatomy of a Terraform Resource Block
#### 25 Essential Terraform Commands

* **`terraform init`**: Initializes a working directory containing Terraform configuration files, downloads necessary provider plugins, and sets up backend storage.
* **`terraform plan`**: Generates and displays an execution preview showing what resources will be created, modified, or destroyed.
* **`terraform apply`**: Executes the actions proposed by the execution plan to provision or update real-world infrastructure.
* **`terraform destroy`**: Completely tears down and deletes all remote infrastructure resources managed by the configuration.
* **`terraform validate`**: Checks the syntax, structure, and internal consistency of configuration files without hitting provider APIs.
* **`terraform fmt`**: Automatically rewrites configuration files to match the canonical HCL formatting and style standard.
* **`terraform show`**: Displays detailed, human-readable attributes of a saved execution plan or current state file.
* **`terraform output`**: Extracts and displays output variables defined within the configuration.
* **`terraform state list`**: Lists all individual resources currently tracked inside the project's state file.
* **`terraform state show`**: Displays detailed attribute data for a specific resource tracked in the state.
* **`terraform state mv`**: Relocates or renames resource addresses within the state file without altering physical infrastructure.
* **`terraform state rm`**: Removes specified resources from state tracking without deleting the actual cloud assets.
* **`terraform state pull`**: Manually downloads and outputs the remote state file contents locally.
* **`terraform state push`**: Manually uploads a local state file directly to the remote storage backend.
* **`terraform import`**: Brings pre-existing, manually created cloud infrastructure under Terraform management by binding it to a resource address.
* **`terraform console`**: Launches an interactive shell session to evaluate and test HCL expressions and interpolation functions.
* **`terraform graph`**: Produces a visual DOT-format diagram representing dependency relationships among configured resources.
* **`terraform workspace new`**: Creates a brand-new isolated workspace for managing separate operational environments.
* **`terraform workspace select`**: Switches the active session to a different designated workspace.
* **`terraform workspace list`**: Displays all available workspaces configured within the project.
* **`terraform workspace show`**: Outputs the name of the currently active workspace.
* **`terraform taint`**: Manually flags a specific resource to be destroyed and re-provisioned from scratch on the next apply.
* **`terraform untaint`**: Removes the taint flag from a resource, preventing it from being automatically forced into re-creation.
* **`terraform force-unlock`**: Manually breaks and releases a stuck state lock using a designated lock ID.
* **`terraform version`**: Prints the currently installed version of the Terraform CLI binary.



  
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


### 4. Variables & Parameterization (`variables.tf`)

Think of `variables.tf` as the **Rulebook** or **Settings Panel** for your project. 

* **The Problem It Solves**: If you hardcode specific names, regions, or IDs directly into your main blueprints (`main.tf`), changing them later requires digging through your core code and risking accidental errors.
* **The Purpose**: It declares customizable slots (variables) that define what data types are allowed, what they mean, and what default values they should fall back on if nothing else is provided.

```hcl
variable "aws_region" {
  type        = string
  description = "The target AWS region for resource deployment"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "The globally unique name of the S3 bucket"
  default     = "shahzad-terraform-resource-test-2026"
}

```

### 5. Custom Values & Settings (`terraform.tfvars`)

Think of `terraform.tfvars` as your **Secret Sticky Note** or **Custom Values Sheet**.

* **The Problem It Solves**: While `variables.tf` establishes the rules and allowed slots, it doesn't store your actual environment-specific settings.
* **The Purpose**: This file provides the real, custom values assigned to those variables for your specific build (like testing vs. production). Keeping values here separates configuration data from core code structure.

```hcl
aws_region  = "us-east-1"
bucket_name = "shahzad-terraform-resource-test-2026"

```

* **How They Connect**: Your `main.tf` file references these values dynamically using the `var.` prefix instead of hardcoding text:

```hcl
resource "aws_s3_bucket" "test_bucket" {
  bucket = var.bucket_name
}

```

### 6. Outputs & Resource References (`outputs.tf`)

Think of `outputs.tf` as the **Scoreboard Window** or **Trophy Room** for your project.

* **The Problem It Solves**: When Terraform finishes building your cloud infrastructure, it quietly saves secret IDs and addresses in its internal memory state file. Without outputs, you would have to go digging through the messy AWS web console just to find your new bucket's address or ID.
* **The Purpose**: It exposes key resource attributes right on your terminal screen the second `terraform apply` finishes, making it easy to read important IDs or share them with other configuration files.

```hcl
output "my_bucket_id" {
  description = "The unique ID/name of our S3 bucket"
  value       = aws_s3_bucket.test_bucket.id
}

output "my_bucket_arn" {
  description = "The Amazon Resource Name (ARN) of our bucket"
  value       = aws_s3_bucket.test_bucket.arn
}

```

* **How Referencing Works**: Instead of using `var.` (which is only for variables), outputs point directly to the built resource's address (`resource_type.local_name.attribute`) to pull its live data directly from Terraform's memory state after deployment.



## 7. Connecting Multiple Resources & Inter-Resource Dependencies

Think of this like building a Lego town where your toy car needs a road to drive on, and your house needs a power line to turn on its lights. 

* **The Problem It Solves**: Real-world cloud applications are never just a single, lonely S3 bucket sitting by itself. They consist of a web of connected pieces—like a Virtual Private Cloud (VPC) network, network subnets, security guard doors (security groups), and computer servers (EC2 instances)—that must interact with one another securely.
* **The Purpose**: It teaches you how to wire multiple cloud resources together so they form a functional architecture.
* **How It Works (Implicit vs. Explicit Dependencies)**: 
  * **Implicit Dependencies**: Terraform is smart. If your subnet needs to know the ID of the VPC before it can be built, you pass the reference directly (e.g., `vpc_id = aws_vpc.main_vpc.id`). Terraform automatically reads this wiring, figures out the puzzle, and builds the VPC *first* before attempting to build the subnet. Nothing breaks because the order of creation is handled automatically!

### Example: Connecting a VPC and a Subnet

```hcl
# 1. Build the foundational cloud land (VPC)
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "production-vpc"
  }
}

# 2. Build a neighborhood block (Subnet) inside that exact VPC
resource "aws_subnet" "public_subnet" {
  # We use the VPC's ID reference here to wire them together!
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet-1"
  }
}
```

### Additional Example: Connecting a Server to a Subnet and Security Guard

In cloud networks, a computer server cannot just sit out in the open; it needs to live inside a neighborhood block (subnet) and have a security guard door (security group) controlling who can talk to it.

```hcl
# 3. Build a Security Guard Door (Security Group) inside our VPC
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow inbound web traffic"
  # We plug the VPC ID right here so the security group knows which network it belongs to!
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Build a Computer Server (EC2 Instance) plugged into our Subnet and Security Group
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  # We plug the Subnet ID here so the server drops into the correct neighborhood block!
  subnet_id     = aws_subnet.public_subnet.id
  
  # We attach our security guard ID here too!
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "my-first-connected-server"
  }
}

```

* **Why This Matters**: Terraform looks at all these references (`aws_vpc.main_vpc.id`, `aws_subnet.public_subnet.id`, `aws_security_group.web_sg.id`) and automatically builds the VPC first, then the Subnet, then the Security Group, and finally turns on the EC2 Server last. It figures out the puzzle entirely on its own!

### Additional Simple Example: An S3 Bucket Notification Trigger

Think of this like a mail slot on a clubhouse door: when a letter (file) is dropped inside, it automatically rings a doorbell (SNS topic) to wake someone up.

```hcl
# 1. Build a Clubhouse Mailbox (S3 Bucket)
resource "aws_s3_bucket" "upload_bucket" {
  bucket = "shahzad-media-upload-bucket-2026"
}

# 2. Build a Doorbell (SNS Topic) that alerts us when something happens
resource "aws_sns_topic" "upload_alerts" {
  name = "bucket-upload-notification-topic"
}

# 3. Connect the Mailbox to the Doorbell using a Notification Rule
resource "aws_s3_bucket_notification" "bucket_notice" {
  # We point directly to our S3 bucket ID here to wire them together!
  bucket = aws_s3_bucket.upload_bucket.id

  topic {
    # We point directly to our SNS topic ARN here so the mailbox knows who to ring!
    topic_arn     = aws_sns_topic.upload_alerts.arn
    events        = ["s3:ObjectCreated:*"]
  }
}
```

* **Why This Matters**: Terraform sees that the notification rule cannot exist until both the bucket and the doorbell are created, and it knows the mailbox must exist before you can hook a notification to it. It automatically figures out the correct construction order without you having to guess or manually sequence them!

### Additional Simple Example: An IAM User and Access Key

Think of this like making a secret clubhouse ID card for a new member: you have to create the person's account *first* before you can hand them a physical key or badge.

```hcl
# 1. Create the Clubhouse Member (IAM User)
resource "aws_iam_user" "new_member" {
  name = "alex-developer-2026"
}

# 2. Create a Security Key Card specifically for that Member
resource "aws_iam_access_key" "member_key" {
  # We link this key directly to our user's name so it belongs to the right person!
  user = aws_iam_user.new_member.name
}
```
* **Why This Matters**: Terraform understands that a security key cannot be generated for a user that doesn't exist yet. It automatically creates the IAM user first, waits for it to finish, and then generates the access key second.


### Additional Simple Example: An EC2 Server and a Permanent Public IP (Elastic IP)

Think of this like buying a brand-new smartphone and assigning it a permanent phone number: you have to unbox and turn on the phone *first* before you can link that special phone number to it.

```hcl
# 1. Build the Smartphone (EC2 Instance)
resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

# 2. Reserve a Permanent Phone Number (Elastic IP) and attach it
resource "aws_eip" "server_ip" {
  # We plug our server ID here so the network knows which server gets this permanent number!
  instance = aws_instance.app_server.id
}
```

* **Why This Matters**: Terraform knows that you cannot attach a permanent public IP address to a server that doesn't exist yet. It automatically creates the EC2 instance first, retrieves its unique ID, and then binds the Elastic IP address to it in the correct order.

### 8. Resource Cleanup & Destruction

Tear down your provisioned infrastructure safely when it is no longer needed to avoid ongoing cloud costs:

```bash
terraform destroy

```
### 9. Workflow Summary & Best Practices

Review the core lifecycle commands for managing your Terraform project:

* **`terraform init`**: Initializes the working directory, downloads provider plugins, and sets up the backend.
* **`terraform plan`**: Previews the execution plan to see what infrastructure changes Terraform will make.
* **`terraform apply`**: Executes the actions proposed in the plan to create or update your cloud architecture.
* **`terraform destroy`**: Completely tears down all resources managed by your configuration to prevent unnecessary cloud costs.

### 9. Troubleshooting & Maintenance

Address common issues encountered during Terraform deployments with these standard troubleshooting commands:

* **`terraform refresh`**: Updates the state file against real-world infrastructure without modifying the actual cloud resources.
* **`terraform validate`**: Checks your configuration files for syntax errors and internal consistency independently of any remote state or provider.
* **`terraform fmt`**: Automatically rewrites configuration files to canonical formatting and style standards.

### 10. Project Directory Structure

Organize your files within the workspace following standard conventions for modularity and maintainability:

```text
my-terraform-project/
├── main.tf          # Core resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Exported resource attributes
├── backend.tf       # Remote state configuration
└── terraform.tfvars # Environment-specific variable values

```
### 11. Next Steps & Conclusion

Review your completed infrastructure setup and proceed with building out your specific AWS cloud modules:

* Verify that your remote state backend bucket and DynamoDB locking table are active.
* Begin writing custom resource declarations inside your `main.tf` file.
* Commit your configuration securely to your version control system while ensuring sensitive files like `.tfvars` are excluded via `.gitignore`.
