provider "aws" {
  region = var.aws_region

  # Tags aplicados automaticamente a todo recurso que los soporte.
  default_tags {
    tags = var.common_tags
  }
}
