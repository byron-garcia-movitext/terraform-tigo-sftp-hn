terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # El state de este proyecto es LOCAL por decision del equipo (terraform.tfstate
  # en esta carpeta). Si algun dia se quiere mover a S3, descomentar lo de abajo
  # y correr: terraform init -migrate-state
  # backend "s3" {
  #   bucket       = "movitext-terraform-state"
  #   key          = "sftp-tigo-hn/terraform.tfstate"
  #   region       = "us-east-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }
}
