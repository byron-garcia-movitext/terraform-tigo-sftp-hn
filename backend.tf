# State remoto en S3 — no se versiona en git.
# Bucket: movi-terraform-s3 | Folder: sftp-tigo-hn/
# Locking nativo de S3 (use_lockfile) — requiere Terraform >= 1.10.
# Primer uso tras clonar:  terraform init
terraform {
  backend "s3" {
    bucket       = "movi-terraform-s3"
    key          = "sftp-tigo-hn/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
