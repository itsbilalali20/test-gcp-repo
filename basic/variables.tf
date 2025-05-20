variable "client_project_id" {
  description = "The client project ID"
  type        = string
  default     = "sys-79467417312192294616159070"
}


variable "region" {
  description = "Region for the provider"
  type        = string
  default     = "us-central1"
}

variable "name_prefix" {
  description = "Prefix for the service account"
  type        = string
  default     = "scaleops"
}

variable "package" {
  description = "Package name to describe the service account"
  type        = string
  default     = "basic"
}

variable "principal" {
  description = "The user, group, or service account to assign the role to"
  type        = string
  default     = "control-project@control-project-460406.iam.gserviceaccount.com"
}

variable "custom_permissions" {
  type = list(string)
  description = "List of permissions for the custom role"
}
