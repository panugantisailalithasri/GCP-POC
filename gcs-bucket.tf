# Cloud Storage bucket matching the reference configuration for
# freyr-ai-pac-superagent-agent-runtime (Configuration / Protection / Lifecycle tabs).

resource "google_project_service" "storage" {
  project            = var.project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "poc" {
  name     = var.bucket_name
  project  = var.project_id
  location = var.location

  depends_on = [google_project_service.storage]

  # Default storage class: Standard
  storage_class = "STANDARD"

  # Location type: Region (implied by a single-region location such as US-CENTRAL1)
  # Hierarchical namespace: Not enabled (omit hierarchical_namespace / keep default off)
  # Replication / turbo replication: not applicable to regional buckets
  # Cross-bucket replication: none
  # Rapid Cache: not configured
  # Labels / tags: none

  # Requester Pays: Off
  requester_pays = false

  # Access control: Uniform (object ACLs disabled)
  uniform_bucket_level_access = true

  # Public access prevention: not enabled on the bucket (inherits org policy only)
  public_access_prevention = "inherited"

  # Object versioning: Off
  versioning {
    enabled = false
  }

  # Soft delete policy: 7 days (screenshot Protection tab)
  # Set retention_duration_seconds = 0 to disable.
  soft_delete_policy {
    retention_duration_seconds = var.soft_delete_retention_days * 24 * 60 * 60
  }

  # Bucket retention policy: none (omit retention_policy)
  # Object retention: not enabled (omit enable_object_retention)
  # Default event-based hold: Disabled (omit default_event_based_hold)

  # Encryption: Google-managed keys (omit encryption block)
  # Google-managed, Cloud KMS, and customer-supplied keys remain allowed.

  # Cross-origin resource sharing: Not enabled (omit cors)
  # Lifecycle rules: none (omit lifecycle_rule)
  # IP filtering: not configured

  force_destroy = var.force_destroy

  # Do not attach a default object ACL; uniform access is required above.
}
