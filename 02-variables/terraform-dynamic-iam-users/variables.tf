variable "environments" {
  description = "Map of environment keys to IAM group names"
  type        = map(string)
}

variable "count_members" {
  description = "Number of IAM users to create per environment"
  type        = map(number)

}

variable "admin_users_per_env" {
  description = "Number of admin users per environment"
  type        = number
}

variable "enable_mfa" {
  description = "Enable MFA for production users"
  type        = bool
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)

}