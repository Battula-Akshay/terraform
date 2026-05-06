# Terraform Docker Nginx Project - Concepts Learned

## Project Overview
Deployed NGINX container locally using Terraform + Docker

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
        source = "kreuzwerker/docker"
        version = "~> 3.0"
      }
    }
  }