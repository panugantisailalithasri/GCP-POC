variable "project_id" {
  description = "GCP project ID that will own the bucket (screenshot project: freyr-ai)."
  type        = string
}

variable "region" {
  description = "Default provider region. The bucket itself is regional in us-central1."
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = <<-EOT
    Globally unique Cloud Storage bucket name.
    Reference bucket was freyr-ai-pac-superagent-agent-runtime; this POC uses a distinct name.
  EOT
  type        = string
  default     = "freyr-ai-poc-storage"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket names must be 3-63 characters, lowercase, and start/end with a letter or number."
  }
}

variable "location" {
  description = "Bucket location. Screenshot: us-central1 (Iowa), location type Region."
  type        = string
  default     = "US-CENTRAL1"
}

variable "force_destroy" {
  description = "If true, Terraform can destroy the bucket even when it still contains objects. Keep false outside throwaway POCs."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Soft-delete retention in days. Screenshot: 7 days."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days == 0 || (var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90)
    error_message = "Soft-delete retention must be 0 (disabled) or between 7 and 90 days."
  }
}

variable "additional_iam_members" {
  description = <<-EOT
    Extra bucket IAM members beyond the default project Owner/Editor/Viewer grants GCP applies on create.
    The reference bucket granted Storage Object Admin to the Vertex AI Reasoning Engine service agent,
    limited by condition title pac-mcp-catalog-prefix.
  EOT
  type = list(object({
    role   = string
    member = string
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = []
}
