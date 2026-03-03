# AGENTS.md - Terraform Infrastructure Project

## Project Overview

This is a Terraform/OpenTofu infrastructure project that manages resources on AWS and Cloudflare (DNS). The project uses OpenTofu (v1.9.1) for infrastructure as code.

## Build, Lint, and Test Commands

### Terraform Commands

```bash
# Initialize Terraform/OpenTofu
tofu init
terraform init

# Validate configuration syntax
tofu validate
terraform validate

# Format Terraform files (auto-fixes style issues)
tofu fmt -recursive
terraform fmt -recursive

# Check for formatting without modifying files
tofu fmt -check -recursive
terraform fmt -check -recursive

# Plan changes (dry run)
tofu plan
terraform plan

# Apply changes
tofu apply
tofu apply -auto-approve  # Non-interactive

# Destroy resources
tofu destroy
tofu destroy -auto-approve

# Show current state
tofu show
terraform show

# List resources in state
tofu state list
terraform state list
```

### Running a Single Test / Check

There is no traditional "test" framework in Terraform, but you can validate specific files:

```bash
# Validate a specific configuration file
tofu validate <path-to-file>

# Plan specific resource only
tofu plan -target=<resource-type>.<resource-name>
```

### CI/CD

The project uses GitHub Actions with OpenTofu. See `.github/workflows/opentofu.yml`:

- Runs on push to `main` and pull requests
- Uses OpenTofu v1.9.1
- Runs `tofu init` and `tofu plan`
- Auto-applies on main branch push

## Code Style Guidelines

### File Organization

- One resource type per file (e.g., `dns.tf`, `ec2.tf`, `rds.tf`)
- Use descriptive file names: `<resource-category>.tf`
- Group related resources in the same file
- Order files alphabetically or by dependency order

### Naming Conventions

- **Resources**: Use lowercase with underscores: `resource "cloudflare_dns_record" "jellyfin"`
- **Variables**: Use lowercase with underscores: `variable "instance_type"`
- **Outputs**: Use lowercase with underscores: `output "instance_id"`
- **Modules**: Use lowercase with dashes: `module "web-server"`
- **Files**: Use lowercase with dashes: `main.tf`, `dns-records.tf`

### Terraform Syntax

```hcl
# Resource naming: resource_type "descriptive_name"
resource "aws_instance" "web_server" {
  # Use 2-space indentation
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  tags = {
    Name = "web-server"
  }
}

# Variables with descriptions
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Outputs with descriptions
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web_server.id
}
```

### Formatting

- Use 2-space indentation (Terraform default)
- Always run `tofu fmt` before committing
- Align arguments within blocks for readability when appropriate
- Use blank lines to separate logical sections

### Variable Definitions

- Always include `description` for all variables
- Use appropriate types (`string`, `number`, `bool`, `list`, `map`, `object`)
- Provide sensible defaults when applicable
- Use validation blocks for constraints

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### Hardcoded Values

- Avoid hardcoding values that should be configurable
- Use variables for: region, instance types, AMI IDs, resource names
- Use `var.*` references instead of hardcoding
- Consider using `terraform.tfvars` or environment-specific files for sensitive data

### Security

- **NEVER commit secrets**: Add `*.tfvars`, `*.env`, `*.json` containing secrets to `.gitignore`
- Use AWS Secrets Manager or similar for sensitive data in production
- Use sensitive flags for sensitive outputs: `sensitive = true`
- Never hardcode API keys, passwords, or tokens in `.tf` files

### State Management

- This project uses S3 backend (see `providers.tf`)
- State is stored in S3 bucket: `hlspace-terraform`
- Never commit `.tfstate` files

### Dependencies

- Use explicit dependencies with `depends_on` when implicit dependencies are not clear
- Reference resources with `resource_type.name.attribute` syntax
- Be careful with cyclic dependencies

### Comments

- Use comments sparingly to explain non-obvious configurations
- Explain *why*, not *what*
- Example: `# Required for TLS termination at ALB`

### Best Practices

1. Always run `tofu fmt` and `tofu validate` before planning/applying
2. Review `tofu plan` output carefully before applying
3. Use `-target` flag sparingly - it can create orphaned resources
4. Keep state synchronized: run `tofu refresh` if needed
5. Use workspaces for environment separation if needed
6. Tag resources consistently for easier management

### Docker Compose (capella directory)

The `capella/` directory contains Docker Compose files for self-hosted services:

```bash
# Start a service
docker compose -f capella/<service>/docker-compose.yml up -d

# Stop a service
docker compose -f capella/<service>/docker-compose.yml down

# View logs
docker compose -f capella/<service>/docker-compose.yml logs -f
```

Required Docker network:
```bash
docker network create proxy
```

## Common Issues

- **Credential errors**: Ensure AWS credentials are configured via environment variables or `~/.aws/credentials`
- **Cloudflare errors**: Set `CLOUDFLARE_API_TOKEN` environment variable
- **State lock**: If state is locked, wait or check for stuck operations in AWS
- **Plan differences**: Run `tofu refresh` if state is out of sync with actual infrastructure
