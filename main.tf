### Putting Code Inside `main.tf`

Now that your empty `main.tf` file is ready, we are going to write the actual instructions inside it. 

Think of this code as telling Terraform two things:
1. What cloud provider we are using (**AWS**).
2. What version of the tools we need so everything speaks the same language.

Here is how to add it:
1. Click on your `main.tf` file in your GitHub repository.
2. Click the little pencil icon (Edit file) near the top right of the file view.
3. Delete anything inside, then copy and paste the code block below:

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

```

