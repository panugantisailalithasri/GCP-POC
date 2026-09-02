#!/usr/bin/env bash
# Shared Terraform entrypoint for Azure DevOps and local CI-style runs.
# Required environment:
#   GOOGLE_CREDENTIALS  service account JSON
#   GCP_PROJECT_ID
#   GCP_BUCKET_NAME
#   TF_STATE_BUCKET
#   TF_STATE_PREFIX     optional, default gcp/poc-storage
#
# Usage: pipelines/run-terraform.sh plan|apply|destroy

set -euo pipefail

ACTION="${1:?usage: $0 plan|apply|destroy}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

: "${GOOGLE_CREDENTIALS:?GOOGLE_CREDENTIALS (service account JSON) is required}"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${GCP_BUCKET_NAME:?GCP_BUCKET_NAME is required}"
: "${TF_STATE_BUCKET:?TF_STATE_BUCKET is required for remote state}"

TF_STATE_PREFIX="${TF_STATE_PREFIX:-gcp/poc-storage}"
OUT_DIR="${ROOT}/ci-out"
mkdir -p "${OUT_DIR}"

cp backend.tf.example backend.tf

cat > terraform.tfvars <<EOF
project_id  = "${GCP_PROJECT_ID}"
bucket_name = "${GCP_BUCKET_NAME}"
location    = "US-CENTRAL1"
region      = "us-central1"
force_destroy = false
soft_delete_retention_days = 7
EOF

terraform init -input=false \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="prefix=${TF_STATE_PREFIX}"

case "${ACTION}" in
  plan)
    terraform plan -input=false -out="${OUT_DIR}/plan.tfplan"
    terraform show -no-color "${OUT_DIR}/plan.tfplan" | tee "${OUT_DIR}/plan.txt"
    ;;
  apply)
    if [[ -f "${OUT_DIR}/plan.tfplan" ]]; then
      terraform apply -input=false "${OUT_DIR}/plan.tfplan"
    else
      terraform apply -input=false -auto-approve
    fi
    ;;
  destroy)
    terraform destroy -input=false -auto-approve
    ;;
  *)
    echo "Unknown action: ${ACTION}" >&2
    exit 1
    ;;
esac
