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

resource "google_project_iam_custom_role" "custom_observability_role" {
  role_id     = "${var.name_prefix}_${var.package}_custom_readonly_role"
  title       = "${var.name_prefix}_${var.package}_custom_readonly_role"
  description = "Custom Readonly Role"
  project     = var.client_project_id 
  permissions = var.custom_permissions
}


resource "google_project_iam_member" "grant_custom_role" {
  project = var.client_project_id
  role    = google_project_iam_custom_role.custom_observability_role.name
  member  = "serviceAccount:${var.principal}"
}

resource "google_project_iam_member" "grant_owner_role" {
  project = var.client_project_id
  role    = "roles/owner"
  member  = "serviceAccount:${var.principal}"
}
