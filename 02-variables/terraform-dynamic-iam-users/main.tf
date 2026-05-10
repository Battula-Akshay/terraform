terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6 "
    }
  }
}

provider "aws" {
  region  = "ap-south-2"
  profile = "aws642"
}

# ================== IAM GROUPS ====================
resource "aws_iam_group" "env" {
  for_each = var.environments
  
  name = each.value
  path = "/groups/${each.key}/"
}

# ==================== DYNAMIC USER GENERATION ====================
locals {
  # Generate users using nested loops
  users = flatten([
    for env, count in var.count_members : [
      for i in range(count) : {
        username    = "${env}-user-${i + 1}"
        environment = env
        user_index  = i + 1
        is_admin    = i < var.admin_users_per_env
      }
    ]
  ])
  
  # Separate users by environment for easier access
  users_by_env = {
    for env in keys(var.environments) : 
    env => [for u in local.users : u if u.environment == env]
  }
  
  # Current date for tags (function calls allowed here)
  current_date = formatdate("YYYY-MM-DD", timestamp())
}

# ==================== IAM USERS ====================
resource "aws_iam_user" "users" {
  count = length(local.users)
  
  name = local.users[count.index].username
  path = "/users/${local.users[count.index].environment}/"
  
  tags = merge(var.common_tags, {
    Environment = local.users[count.index].environment
    UserIndex   = tostring(local.users[count.index].user_index)
    AccessLevel = local.users[count.index].is_admin ? "admin" : "readonly"
    CreatedDate = local.current_date
  })
}

# ==================== ADD USERS TO GROUPS ====================
resource "aws_iam_user_group_membership" "membership" {
  count = length(local.users)
  
  user = aws_iam_user.users[count.index].name
  
  groups = [
    aws_iam_group.env[local.users[count.index].environment].name
  ]
}

# ==================== ATTACH IAM POLICIES (Admin vs ReadOnly) ====================
resource "aws_iam_user_policy_attachment" "user_policies" {
  count = length(local.users)
  
  user = aws_iam_user.users[count.index].name
  
  policy_arn = local.users[count.index].is_admin ? "arn:aws:iam::aws:policy/AdministratorAccess" : "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ==================== MFA FOR PRODUCTION USERS ====================
resource "aws_iam_user_login_profile" "prod_mfa" {
  for_each = var.enable_mfa ? {
    for user in local.users : 
    user.username => user if user.environment == "prod"
  } : {}
  
  user = each.key
  password_length = 16
  password_reset_required = true
}

# ==================== RANDOM PASSWORDS FOR NON-PROD USERS ====================
resource "random_password" "user_passwords" {
  for_each = {
    for user in local.users : 
    user.username => user if user.environment != "prod"
  }
  
  length  = 16
  special = true
  numeric = true
}

# ==================== CREATE ACCESS KEYS ====================
resource "aws_iam_access_key" "user_keys" {
  count = length(local.users)
  
  user = aws_iam_user.users[count.index].name
  status = "Active"
}
