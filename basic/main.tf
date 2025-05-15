terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "google" {
  project = var.client_project_id
  region  = var.region
}


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

resource "google_project_iam_custom_role" "custom_observability_role" {
  role_id     = "${var.name_prefix}_${var.package}_custom_readonly_role"
  title       = "${var.name_prefix}_${var.package}_custom_readonly_role"
  description = "Custom Readonly Role"
  project     = var.client_project_id 
  permissions = var.custom_permissions
}
