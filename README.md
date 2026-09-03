# Freyr-AI POC — GCP Cloud Storage

Terraform for a regional Cloud Storage bucket that mirrors `freyr-ai-pac-superagent-agent-runtime`, using a POC bucket name.

This repo is currently set up for local Terraform execution first.

Additional documentation:

- `docs/cursor-github-origin-guide.md` - how GitHub was connected to Cursor, how this repo was pushed from Cursor/Origin to GitHub, and what Cursor Codebase / Origin means

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

## Clone and run locally

```bash
git clone <your-github-repo-url>
cd <repo>
cp terraform.tfvars.example terraform.tfvars
# set project_id and a globally unique bucket_name
```

Prerequisites:

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.6` (this repo pins `1.11.4` in `.terraform-version`)
- GCP credentials, for example:

```bash
gcloud auth application-default login
gcloud config set project freyr-ai
```

Bucket names are **globally unique**. If `freyr-ai-poc-storage` is taken, change `bucket_name`.

Quick start:

```bash
./scripts/local-terraform.sh plan
./scripts/local-terraform.sh apply
```

Or run Terraform directly:

```bash
terraform init
terraform plan
terraform apply
```

Optional remote state for local use: create a **separate** state bucket once — do not store state in the POC resource bucket:

```bash
gcloud storage buckets create gs://freyr-ai-poc-tfstate \
  --project=freyr-ai \
  --location=us-central1 \
  --uniform-bucket-level-access

cp backend.tf.example backend.tf
cp backend.hcl.example backend.hcl
# edit backend.hcl if your state bucket/prefix differ

terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

`terraform.tfvars`, `backend.hcl`, and `backend.tf` are gitignored so local values and generated backend files stay off GitHub.

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
| `backend.tf.example` | Optional GCS remote state block |
| `backend.hcl.example` | Local backend config (copy to `backend.hcl`) |
| `scripts/local-terraform.sh` | Local helper for init/plan/apply/destroy |
