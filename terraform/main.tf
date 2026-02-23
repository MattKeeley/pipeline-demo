# DEMO ONLY: Do not store real secrets in Terraform outputs or variables.
# This config illustrates how secrets in outputs can be exfiltrated in CI.

variable "db_password" {
  description = "Sensitive value - in CI, pass from repo secret TOP_SECRET_SECRET"
  type        = string
  sensitive   = true
}

# Output exposes the secret; any step in the same CI job can read it via:
#   terraform output -raw db_password
output "db_password" {
  description = "Secret exposed as output - dangerous in shared CI"
  value       = var.db_password
  sensitive   = true
}
