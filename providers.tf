provider "google" {
  project = var.project_id
  region  = var.region

  # Local:  gcloud auth application-default login
  # ADO:    set GOOGLE_CREDENTIALS to the service account JSON (secret variable)
}
