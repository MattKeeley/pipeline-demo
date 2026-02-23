# pipeline-demo

This repo showcases **two GitHub Actions security issues** for educational use only: Terraform output secret exfiltration and workflow-controlled secret exposure.

## Examples

1. **Terraform output exfiltration**  
   Secrets in Terraform outputs can be read by any step in CI. A “malicious” step can print them character-by-character to bypass GitHub’s log masking.  
   - Workflow: [.github/workflows/terraform-exfil-demo.yml](.github/workflows/terraform-exfil-demo.yml)  
   - Docs: [docs/terraform-exfil.md](docs/terraform-exfil.md)

2. **Workflow-controlled secret exposure**  
   If an attacker can add or change workflow files, they can print (or exfiltrate) `GITHUB_TOKEN` and repo/org secrets, again using character spacing to bypass masking.  
   - Workflow: [.github/workflows/workflow-secrets-demo.yml](.github/workflows/workflow-secrets-demo.yml)  
   - Docs: [docs/workflow-secrets.md](docs/workflow-secrets.md)

## How to run

- Push to the default branch or trigger the workflows via **Actions → workflow → Run workflow**.
- For the **workflow-secrets** demo: add a repo secret named `TOP_SECRET_SECRET` in **Settings → Secrets and variables → Actions** with a **dummy value** (e.g. `fake_demo_secret`) so the workflow can run.

## Disclaimer and safe usage

**Do not run these workflows on repositories that use real secrets.** They are intended to demonstrate how secrets can be exposed; use only:

- A **dedicated test org/repo**, and  
- **Dummy or placeholder values** for any Terraform variables and repo secrets.

No real secrets should be stored in this repo or in Terraform configs used by these workflows.
