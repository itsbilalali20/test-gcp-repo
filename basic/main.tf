terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

#######################
# VARIABLES
#######################
variable "gcp_project" {
  description = "Target GCP project ID"
  type        = string
  default     = "sys-79467417312192294616159070"
}

variable "main_project" {
  description = "Main GCP project ID (can impersonate)"
  type        = string
  default     = "scaleops-test"
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "scaleops-testt"
}

variable "package" {
  description = "Package name suffix"
  type        = string
  default     = "basic"
}

variable "gcp_region" {
  description = "GCP region (for provider settings)"
  type        = string
  default     = "us-central1"
}

#######################
# SERVICE ACCOUNTS
#######################
resource "google_service_account" "readonly" {
  account_id   = "${var.prefix}-${var.package}-readonly"
  display_name = "Read-only Service Account"
}

resource "google_service_account" "monitoring" {
  account_id   = "${var.prefix}-${var.package}-monitoring"
  display_name = "Monitoring Service Account"
}

#######################
# CUSTOM ROLES
#######################
resource "google_project_iam_custom_role" "gkescan" {
  role_id     = "${var.prefix}_${var.package}_GkeScanRole"
  title       = "${var.prefix}_${var.package} GkeScanRole"
  description = "Policy for scanning GKE clusters for compliance"
  project     = var.gcp_project

  permissions = [
    "container.clusters.list",
    "container.clusters.get",
    "container.nodes.list",
    "container.nodes.get",
    "container.clusterRoles.list",
    "container.clusterRoles.get",
  ]
}

resource "google_project_iam_custom_role" "monitoring" {
  role_id     = "${var.prefix}_${var.package}_MonitoringRole"
  title       = "${var.prefix}_${var.package} MonitoringRole"
  description = "Policy for monitoring resources via Cloud Monitoring & Logging"
  project     = var.gcp_project

  permissions = [
    "monitoring.alertPolicies.get",
    "monitoring.alertPolicies.list",
    "monitoring.metricDescriptors.get",
    "monitoring.metricDescriptors.list",
    "monitoring.timeSeries.list",
    "monitoring.dashboards.create",
    "monitoring.dashboards.update",
    "monitoring.dashboards.get",
    "logging.logEntries.list",
    "logging.logMetrics.list",
    "logging.logMetrics.get",
    "logging.sinks.get",
    "logging.sinks.list",
  ]
}

#######################
# PROJECT-LEVEL IAM BINDINGS
#######################
# ReadOnly SA: Viewer + GkeScanRole
resource "google_project_iam_member" "readonly_viewer" {
  project = var.gcp_project
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.readonly.email}"
}

resource "google_project_iam_member" "readonly_gkescan" {
  project = var.gcp_project
  role    = google_project_iam_custom_role.gkescan.name
  member  = "serviceAccount:${google_service_account.readonly.email}"
}

# Monitoring SA: MetricWriter + Logging Viewer + MonitoringRole
resource "google_project_iam_member" "monitoring_metric_writer" {
  project = var.gcp_project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.monitoring.email}"
}

resource "google_project_iam_member" "monitoring_logging_viewer" {
  project = var.gcp_project
  role    = "roles/logging.viewer"
  member  = "serviceAccount:${google_service_account.monitoring.email}"
}

resource "google_project_iam_member" "monitoring_custom" {
  project = var.gcp_project
  role    = google_project_iam_custom_role.monitoring.name
  member  = "serviceAccount:${google_service_account.monitoring.email}"
}

#######################
# SERVICE ACCOUNT IMPERSONATION
#######################
# Allow only the main_project to impersonate
resource "google_service_account_iam_member" "readonly_impersonation" {
  service_account_id = google_service_account.readonly.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.main_project}@${var.main_project}.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "monitoring_impersonation" {
  service_account_id = google_service_account.monitoring.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.main_project}@${var.main_project}.iam.gserviceaccount.com"
}

#######################
# OUTPUTS
#######################
output "readonly_service_account_email" {
  description = "Read-only SA email"
  value       = google_service_account.readonly.email
}

output "monitoring_service_account_email" {
  description = "Monitoring SA email"
  value       = google_service_account.monitoring.email
}
