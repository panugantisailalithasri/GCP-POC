# Freyr-AI POC — GCP Cloud Storage

Terraform for a regional Cloud Storage bucket that mirrors the configuration of `freyr-ai-pac-superagent-agent-runtime`, using a POC bucket name.

## What this creates

| Setting | Value (matches the reference bucket) |
| --- | --- |
| Name | `freyr-ai-poc-storage` (override in `terraform.tfvars`) |
| Location type | Region |
| Location | `us-central1` (Iowa) |
| Default storage class | Standard |
| Hierarchical namespace | Off |
| Requester Pays | Off |
| Access control | Uniform |
| Public access prevention | Inherited (not enforced on the bucket) |
| Public access | Not public |
| Soft delete | 7 days |
| Object versioning | Off |
| Bucket / object retention | None / disabled |
| Default event-based hold | Disabled |
| Encryption | Google-managed |
| CORS | Not configured |
| Lifecycle rules | None |
| Labels / tags | None |

GCP still applies the default project IAM on create:

- Owners of the project → Storage Legacy Bucket Owner
- Editors of the project → Storage Legacy Bucket Owner
- Viewers of the project → Storage Legacy Bucket Reader and Storage Legacy Object Reader

Extra principals (for example the Vertex AI Reasoning Engine service agent with the `pac-mcp-catalog-prefix` condition) are optional; see `terraform.tfvars.example`.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.6`
- A GCP project with the Cloud Storage API enabled
- Credentials that can create buckets, for example:

```bash
gcloud auth application-default login
gcloud config set project freyr-ai
```

Bucket names are **globally unique**. If `freyr-ai-poc-storage` is taken, change `bucket_name` in `terraform.tfvars`.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars — at least project_id and bucket_name

terraform init
terraform plan
terraform apply
```

After apply, Terraform prints `bucket_name`, `bucket_url` (`gs://...`), and `console_url`.

Destroy:

```bash
terraform destroy
```

`force_destroy` is `false` by default, so destroy fails if the bucket still has objects. Set it to `true` only for a throwaway POC.

## Files

| File | Purpose |
| --- | --- |
| `versions.tf` | Terraform and Google provider versions |
| `providers.tf` | Google provider |
| `variables.tf` | Inputs |
| `gcs-bucket.tf` | Bucket resource |
| `iam.tf` | Optional extra IAM members |
| `outputs.tf` | Name, URI, console URL |
| `terraform.tfvars.example` | Sample values (copy to `terraform.tfvars`) |
