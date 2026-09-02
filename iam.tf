# Default project-level grants (Owners / Editors / Viewers) are applied by GCP
# when the bucket is created, matching the Permissions tab:
#   - Owners of project  -> roles/storage.legacyBucketOwner
#   - Editors of project -> roles/storage.legacyBucketOwner
#   - Viewers of project -> roles/storage.legacyBucketReader
#                          roles/storage.legacyObjectReader
#
# Those defaults are left unmanaged so Terraform does not replace them.
# Additional principals (for example the Vertex AI Reasoning Engine agent)
# are granted below.

resource "google_storage_bucket_iam_member" "additional" {
  for_each = {
    for idx, binding in var.additional_iam_members :
    "${binding.role}:${binding.member}:${try(binding.condition.title, "unconditional")}" => binding
  }

  bucket = google_storage_bucket.poc.name
  role   = each.value.role
  member = each.value.member

  dynamic "condition" {
    for_each = each.value.condition == null ? [] : [each.value.condition]
    content {
      title       = condition.value.title
      description = try(condition.value.description, null)
      expression  = condition.value.expression
    }
  }
}
