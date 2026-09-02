# Freyr-AI POC — GCP Cloud Storage

Terraform for a regional Cloud Storage bucket that mirrors `freyr-ai-pac-superagent-agent-runtime`, using a POC bucket name.

Work on this repo in GitHub so you can clone it locally. The same tree is what Azure DevOps will run later (`azure-pipelines.yml`).

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

Local state (fine for a first test on your machine):

```bash
terraform init
terraform plan
terraform apply
```

Shared / pipeline state (use this before you point ADO at the repo). Create a **separate** state bucket once — do not store state in the POC resource bucket:

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

## Azure DevOps

`azure-pipelines.yml` is the pipeline ADO should use after this GitHub repo is connected as the pipeline source.

| Event | What runs |
| --- | --- |
| Pull request | `terraform fmt -check`, `validate`, `plan` |
| Push to `main` | same (plan only) |
| Manual run with action **apply** or **destroy** | plan, then apply/destroy after environment approval |

### One-time ADO setup

1. Create the GitHub repository and import/connect it in Azure DevOps (**Pipelines → New pipeline → GitHub**).
2. Create variable group `gcp-terraform-poc`:

   | Variable | Secret | Purpose |
   | --- | --- | --- |
   | `GCP_PROJECT_ID` | no | GCP project, e.g. `freyr-ai` |
   | `GCP_BUCKET_NAME` | no | Globally unique bucket name |
   | `GCP_SA_JSON` | **yes** | Service account JSON key |
   | `TF_STATE_BUCKET` | no | Existing GCS bucket for Terraform state |
   | `TF_STATE_PREFIX` | no | e.g. `gcp/poc-storage` |

3. Create environment `gcp-poc` and add an **approval check** so apply/destroy cannot run unattended.
4. Grant the pipeline service account:
   - `roles/storage.admin` on the GCP project (bucket create/manage)
   - `roles/serviceusage.serviceUsageAdmin` if the Storage API might not be enabled
   - object admin on `TF_STATE_BUCKET`

Do not check a service-account JSON into Git. ADO injects `GCP_SA_JSON` as `GOOGLE_CREDENTIALS` at runtime.

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
| `backend.tf.example` | GCS remote state (ADO copies this to `backend.tf`) |
| `backend.hcl.example` | Local backend config (copy to `backend.hcl`) |
| `azure-pipelines.yml` | Azure DevOps pipeline |
| `pipelines/run-terraform.sh` | Plan/apply/destroy used by ADO |
| `pipelines/install-terraform.yml` | Installs the pinned Terraform version on the agent |
