# Secure Terraform Pattern

`for_each` over `count`, `prevent_destroy` on stateful resources, data sources instead of
hardcoded IDs, remote state with locking. Scan with `checkov`/`tfsec` before committing.

```hcl
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state with locking — never local state for shared infrastructure.
  backend "s3" {
    bucket         = "terraform-state-prod"
    key            = "app/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

# Dynamic values via data sources — never hardcoded AMI IDs or AZs.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"]
  }
}

variable "instances" {
  description = "Instances by name"
  type        = map(object({ size = string }))
  default = {
    web    = { size = "t3.small" }
    worker = { size = "t3.medium" }
  }
}

resource "aws_instance" "this" {
  # for_each keeps identities stable when entries are added/removed.
  for_each = var.instances

  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value.size

  metadata_options {
    http_tokens   = "required" # IMDSv2 — blocks SSRF-style credential theft
    http_endpoint = "enabled"
  }

  tags = {
    Name = each.key
  }
}

resource "aws_db_instance" "primary" {
  identifier     = "app-primary"
  engine         = "postgres"
  engine_version = "16"

  storage_encrypted = true

  # Stateful resources are protected from accidental destroy.
  lifecycle {
    prevent_destroy = true
  }
}
```
