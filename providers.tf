provider "google" {
  project = var.project_id
  region  = var.region

  # Local auth example:
  #   gcloud auth application-default login
}
