#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-plan}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${ROOT}"

if [[ ! -f terraform.tfvars ]]; then
  echo "terraform.tfvars not found. Create it from terraform.tfvars.example first." >&2
  exit 1
fi

case "${ACTION}" in
  init)
    terraform init
    ;;
  plan)
    terraform init
    terraform plan
    ;;
  apply)
    terraform init
    terraform apply
    ;;
  destroy)
    terraform init
    terraform destroy
    ;;
  *)
    echo "Usage: $0 {init|plan|apply|destroy}" >&2
    exit 1
    ;;
esac
