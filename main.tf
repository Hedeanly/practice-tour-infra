# ============================================
# APIs
# ============================================
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secret_manager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloud_build" {
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "firestore" {
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "maps" {
  service            = "maps-backend.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "places" {
  service            = "places-backend.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "geocoding" {
  service            = "geocoding-backend.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "monitoring" {
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

# ============================================
# Artifact Registry
# ============================================
resource "google_artifact_registry_repository" "practice_tour_repo" {
  location      = var.region
  repository_id = "practice-tour-repo"
  format        = "DOCKER"
  description   = "Docker images for tour guide app"

  depends_on = [google_project_service.artifact_registry]
}

# ============================================
# Firestore Database
# ============================================
resource "google_firestore_database" "default" {
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.firestore]
}

# ============================================
# Service Accounts
# ============================================
resource "google_service_account" "api_service" {
  account_id   = "sa-api-service"
  display_name = "API Service Account"
}

resource "google_service_account" "maps_service" {
  account_id   = "sa-maps-service"
  display_name = "Maps Service Account"
}

resource "google_service_account" "llm_service" {
  account_id   = "sa-llm-service"
  display_name = "LLM Service Account"
}

resource "google_service_account" "github_actions" {
  account_id   = "sa-github-actions"
  display_name = "GitHub Actions CI/CD"
}

# ============================================
# IAM Bindings — Least Privilege
# ============================================

# API service → Firestore read/write
resource "google_project_iam_member" "api_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.api_service.email}"
}

# Maps service → read secrets
resource "google_project_iam_member" "maps_secrets" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.maps_service.email}"
}

# LLM service → read secrets
resource "google_project_iam_member" "llm_secrets" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.llm_service.email}"
}

# LLM service → Firestore read/write
resource "google_project_iam_member" "llm_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.llm_service.email}"
}

# GitHub Actions — CI/CD roles
resource "google_project_iam_member" "github_cloudbuild" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_storage" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_project_iam_member" "github_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}
