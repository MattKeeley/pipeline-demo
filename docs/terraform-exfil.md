# Terraform output secret exfiltration (demo)

This example shows how secrets stored in Terraform outputs can be exfiltrated in CI and printed in plaintext by bypassing GitHub Actions log masking.

## What’s in this example

- **Terraform:** [terraform/main.tf](../terraform/main.tf) defines a sensitive variable `db_password` and an `output` that exposes it. A state file ([terraform/terraform.tfstate](../terraform/terraform.tfstate)) is committed so `terraform output` works after `terraform plan` (output reads from state).
- **Workflow:** [.github/workflows/terraform-exfil-demo.yml](../.github/workflows/terraform-exfil-demo.yml) runs `terraform plan`. A later step runs `terraform output -raw db_password` and prints it (masked), then pipes it through char-by-char so the value appears in the log unmasked.

## Why this is dangerous

- **Secrets in the job:** Passing secrets into the job for Terraform (e.g. as `TF_VAR_*`) makes them available to every step in that job. The same applies to secrets in Terraform outputs after an apply—any step can run `terraform output` and read them.
- **Log masking is not a security boundary:** GitHub redacts whole secret values in logs. Printing the value with spaces (or other characters) between each character prevents the redaction pattern from matching, so the full secret can be recovered from the log.

## Mitigations

- **Do not put secrets in Terraform outputs.** Use a secrets manager or OIDC/short-lived credentials; reference them at runtime, not via `terraform output`.
- **Restrict who can change workflows.** Require review for `.github/` changes and limit who can approve.
- **Limit scope of credentials.** Use minimal permissions and short-lived tokens (e.g. OIDC with GitHub Actions) instead of long-lived secrets in Terraform state or outputs.
- **Treat CI as untrusted for secrets.** Assume any step in a job can read any secret available in that job; design so exfiltration does not expose anything sensitive.

## Safe usage

Add the repo secret **TOP_SECRET_SECRET** in Settings → Secrets (same as the workflow-secrets demo) with a dummy value. Use only a dedicated test repo; do not run this workflow with real secrets.
