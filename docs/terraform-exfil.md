# Terraform output secret exfiltration (demo)

This example shows how secrets stored in Terraform outputs can be exfiltrated in CI and printed in plaintext by bypassing GitHub Actions log masking.

## What’s in this example

- **Terraform:** [terraform/main.tf](../terraform/main.tf) defines a sensitive variable `db_password` (supplied in CI from the repo secret **TOP_SECRET_SECRET**) and an `output` that exposes it. Any process that can run `terraform output -raw <name>` can read the value.
- **Workflow:** [.github/workflows/terraform-exfil-demo.yml](../.github/workflows/terraform-exfil-demo.yml) runs Terraform, then a “malicious” step that:
  1. Prints the output directly (GitHub masks it).
  2. Prints the same value character-by-character with spaces between each character so the masker does not match, and the secret appears in the log.

## Why this is dangerous

- **Secrets in outputs:** Putting secrets in Terraform outputs (or in state and exposing them via outputs) makes them available to anyone or any step that can run `terraform output` in that environment (e.g. every step in the same job).
- **Log masking is not a security boundary:** GitHub redacts whole secret values in logs. Printing the value with spaces (or other characters) between each character prevents the redaction pattern from matching, so the full secret can be recovered from the log.

## Mitigations

- **Do not put secrets in Terraform outputs.** Use a secrets manager or OIDC/short-lived credentials; reference them at runtime, not via `terraform output`.
- **Restrict who can change workflows.** Require review for `.github/` changes and limit who can approve.
- **Limit scope of credentials.** Use minimal permissions and short-lived tokens (e.g. OIDC with GitHub Actions) instead of long-lived secrets in Terraform state or outputs.
- **Treat CI as untrusted for secrets.** Assume any step in a job can read any secret available in that job; design so exfiltration does not expose anything sensitive.

## Safe usage

Add the repo secret **TOP_SECRET_SECRET** in Settings → Secrets (same as the workflow-secrets demo) with a dummy value. Use only a dedicated test repo; do not run this workflow with real secrets.
