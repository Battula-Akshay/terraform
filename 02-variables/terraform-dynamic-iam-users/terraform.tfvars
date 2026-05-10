environments = {
  dev     = "development"
  staging = "staging"
  prod    = "production"
}

count_members = {
  dev     = 3
  staging = 2
  prod    = 4
}

enable_mfa = true
admin_users_per_env = 2

common_tags = {
  ManagedBy   = "Terraform"
  Project     = "Multi-Environment-IAM"
  Owner       = "DevOps-Team"
  CostCenter  = "12345"
}