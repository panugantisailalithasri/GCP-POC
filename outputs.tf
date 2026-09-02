output "bucket_name" {
  description = "Created bucket name."
  value       = google_storage_bucket.poc.name
}

output "bucket_url" {
  description = "Cloud Storage URI (gs://...)."
  value       = google_storage_bucket.poc.url
}

output "bucket_self_link" {
  description = "API self link for the bucket."
  value       = google_storage_bucket.poc.self_link
}

output "console_url" {
  description = "Google Cloud Console browser URL for the bucket."
  value       = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.poc.name}?project=${var.project_id}"
}

output "location" {
  description = "Bucket location."
  value       = google_storage_bucket.poc.location
}

output "storage_class" {
  description = "Default storage class."
  value       = google_storage_bucket.poc.storage_class
}

output "uniform_bucket_level_access" {
  description = "Whether uniform bucket-level access is enabled."
  value       = google_storage_bucket.poc.uniform_bucket_level_access
}
