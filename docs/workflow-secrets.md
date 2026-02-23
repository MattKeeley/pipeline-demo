# Workflow-controlled secret exposure (demo)

This example shows how an attacker who can add or modify workflow files can expose **GITHUB_TOKEN** and **repository** (and **organization**) secrets. It demonstrates the character-spacing bypass so the secrets appear in plaintext in the Actions log.

## What’s in this example

- **Workflow:** [.github/workflows/workflow-secrets-demo.yml](../.github/workflows/workflow-secrets-demo.yml) has steps that:
  1. Echo `secrets.GITHUB_TOKEN` directly (GitHub redacts it).
  2. Echo the same token with a space between each character so redaction does not match and the token is visible in the log.
  3. Do the same for a repo secret `TOP_SECRET_SECRET` (you must add this in Settings → Secrets with a dummy value to run the demo).

## Threat model

- **Who:** Anyone who can add or change workflow files (e.g. via PR, compromised maintainer, or repo takeover).
- **What:** They can run arbitrary steps that have access to:
  - **GITHUB_TOKEN** (always available to the workflow).
  - **Repository secrets** (any secret configured for the repo).
  - **Organization secrets** (any org secret this repo is allowed to use).
- **How:** A step can print or exfiltrate these values. Direct `echo` is masked; using `sed 's/./& /g'` (or similar) to insert characters between each character bypasses the masker so the full secret can be recovered from the log.

## Why the bypass works

GitHub Actions masks secrets by matching the **exact** secret value in log output. If the value is altered (e.g. a space between every character), the pattern no longer matches and the log is not redacted. An attacker can then reconstruct the secret from the log (e.g. by removing the spaces).

## Mitigations

- **Branch protection:** Require PR reviews for `.github/` and limit who can merge.
- **Least privilege:** Give GITHUB_TOKEN and repo/org secrets only the permissions they need; use fine-grained tokens where possible.
- **Audit workflow changes:** Review workflow diffs carefully; treat new or modified steps as security-sensitive.
- **Limit org secret access:** Only grant org secrets to repos that need them.
- **Assume workflows are powerful:** Anyone who can change a workflow can run code and read all secrets available to that workflow.

## Safe usage

- Use a **dedicated test repo** and only **dummy values** for any repo (or org) secrets.
- Add a repo secret named `TOP_SECRET_SECRET` with a fake value (e.g. `fake_repo_secret_123`) in Settings → Secrets so the workflow runs without errors.
- Do not run this workflow on repos that contain real secrets.
