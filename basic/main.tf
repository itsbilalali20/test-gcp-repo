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

#####################
#   Variables with Defaults
#####################

variable "client_project_id" {
  description = "The client project ID"
  type        = string
  default     = "sys-79467417312192294616159070"
}

variable "control_project_id" {
  description = "The control project ID"
  type        = string
  default     = "scaleops-test"
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

#####################
#   Service Account
#####################

resource "google_service_account" "readonly_sa" {
  account_id   = "${var.name_prefix}-${var.package}-readonly-sa"
  display_name = "Read-only Service Account for ${var.package} package"
}

############################
#   IAM: Read-only Role
############################

resource "google_project_iam_member" "readonly_viewer" {
  project = var.client_project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.readonly_sa.email}"
}

##########################################
#   IAM: Allow Control Project to Impersonate
##########################################

resource "google_service_account_iam_member" "impersonation" {
  service_account_id = google_service_account.readonly_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "control-account-svc-acc@scaleops-test.iam.gserviceaccount.com"
}
