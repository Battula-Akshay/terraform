# Terraform Docker Nginx Project - Concepts Learned

## Project Overview
Deployed NGINX container locally using Terraform + Docker

---

## Version Constraint Operators

| Operator | Description | Example | Matches |
|----------|-------------|---------|---------|
| `>= 1.0` | Greater than or equal to | `>= 1.0` | 1.0, 1.5, 2.0 |
| `<= 1.0` | Less than or equal to | `<= 1.0` | 0.9, 1.0 |
| `~> 2.0` | Any version in the 2.X range (pessimistic constraint) | `~> 2.0` | 2.0, 2.5 (not 3.0) |
| `>= 2.10, <= 2.30` | Range between versions | `>= 2.10, <= 2.30` | 2.10 to 2.30 |

**Common patterns:**
- `~> 1.2.0` → Only patch updates (1.2.x)
- `~> 1.2` → Minor updates (1.x.x)
- `>= 1.0, < 2.0` → Any 1.x version

---

## Core Terraform Concepts Used

### 1. **Providers**
- **What**: Plugins that allow Terraform to interact with APIs
- **3 Types:**
  - **Official** (by HashiCorp) - AWS, Azure, GCP, Random, Local
  - **Partner** (by technology companies) - Datadog, Elastic, etc.
  - **Community** (by open source developers) - Docker (kreuzwerker)
- **Our provider**: `kreuzwerker/docker` (Community provider)
- **Syntax**:
  ```hcl
  terraform {
    required_providers {
      docker = {
        source  = "kreuzwerker/docker"
        version = "~> 3.0"    # Any 3.x version
      }
    }
  }
2. Resources
What: Infrastructure components to create/manage

Format: resource "type" "name"

Our resources:

docker_image.nginx - Pulls Docker image

docker_container.nginx - Creates container

Resource lifecycle: Create → Read → Update → Delete (CRUD)

3. Arguments & Attributes
Arguments: Values you SET (like name, image, ports)

Attributes: Values you GET (like image_id from docker_image)

Attribute reference: docker_image.nginx.image_id (resource.name.attribute)

4. Outputs
What: Display information after apply

Use cases: IP addresses, URLs, resource IDs

Our outputs:

hcl
output "container_id" {
  value = docker_container.nginx.id
}
output "access_url" {
  value = "http://localhost:8080"
}
View outputs: terraform output

5. Port Mapping
What: Map container port to host port

Syntax:

hcl
ports {
  internal = 80   # Container's port
  external = 8080 # Your machine's port
}
Terraform State Management
What is State?
Terraform state is a mapping between your configuration and real-world infrastructure.

Types of State:
State Type	Description	Where it exists
Desired State	What you WANT (your .tf files)	Your code
Current State	What actually EXISTS (real infrastructure)	Docker daemon, AWS, etc.
Recorded State	What Terraform THINKS exists	terraform.tfstate file
State Flow:
text
Your Code (Desired)
      ↓
terraform plan (Compares)
      ↓
Current Infrastructure (Current State)
      ↓
terraform apply (Reconciles)
      ↓
terraform.tfstate (Recorded State)
Important State Concepts:
1. Default Values & Desired State
"These default values are generally not considered to be your desired state."

What this means:

Default values (like a security group allowing nothing by default) are implicit

If you don't specify them, Terraform ignores them in future plans

Example: If you don't set keep_locally = false, Terraform won't track changes to this default

Why it matters:

hcl
# If you DON'T specify keep_locally
resource "docker_image" "nginx" {
  name = "nginx:latest"        # keep_locally defaults to false
}

# If you manually change keep_locally in state file to true
# Terraform WILL NOT detect this change in next plan!
# Because default values aren't tracked as desired state
2. Manual State Changes Have No Impact
"If you manually change these default values, it will have no impact in next terraform plan and apply stages"

Why: Terraform only compares:

Your configuration (what you wrote)

The state file (what Terraform knows)

Actual infrastructure (what really exists)

Manual edits to defaults in state file are ignored because:

Terraform can't tell if you intended the change

Defaults are re-evaluated each run

Only explicit configuration overrides are tracked

3. The terraform refresh Command
"The terraform refresh command will check the latest state of your infrastructure and update the state file accordingly."

What it does:

Queries real infrastructure (Docker, AWS, etc.)

Updates terraform.tfstate to match reality

Does NOT modify your configuration files

When to use:

bash
# If someone manually changed infrastructure outside Terraform
docker stop terraform-nginx-demo    # Manual change

# Refresh updates state file to show container is stopped
terraform refresh

# Now plan will show the drift and how to fix it
terraform plan
State Commands Reference:
Command	Purpose
terraform state list	List all resources in state
terraform state show <resource>	Show details of specific resource
terraform state rm <resource>	Remove resource from state (doesn't delete infra)
terraform refresh	Update state file to match real infra
terraform plan	Compares state + config vs real infra
State File Locations:
Mode	File/Backend	Best for
Local	terraform.tfstate	Learning, personal projects
Remote	S3, Azure Storage, GCS	Team collaboration
Terraform Cloud	HashiCorp's platform	Enterprise
Common State Problems & Solutions:
Problem	Solution
State file has secrets	Use remote backend with encryption
Team members overwriting state	Remote state + locking (DynamoDB)
State file deleted	Restore from backup or terraform import
Drift (manual changes)	terraform refresh then terraform plan
Resource deleted manually	terraform apply recreates it
Example: Detecting Drift
bash
# 1. Initial state - container running
terraform apply    # Creates container

# 2. Manual change outside Terraform
docker stop terraform-nginx-demo

# 3. Detect drift
terraform plan     # Shows: container needs to be updated

# 4. Or refresh first
terraform refresh  # Updates state to show stopped
terraform plan     # Shows: container needs to be recreated
Terraform Commands Used
Command	Purpose	When to use
terraform init	Downloads providers, sets up backend	First time, or when providers change
terraform plan	Preview changes (read-only)	Before apply, to see what will happen
terraform apply	Create/update resources	To make changes
terraform destroy	Delete all resources	Cleanup
terraform state list	List resources in state	Debugging
terraform show	Show current state	Inspection
terraform refresh	Sync state with real infrastructure	When manual changes happened
terraform output	Display output values	After apply
