###############################################################################
# Instancia EC2
###############################################################################

resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address

  monitoring              = var.monitoring
  disable_api_termination = var.disable_api_termination
  user_data               = var.user_data

  # IMDSv2 obligatorio: evita que un SSRF en la instancia pueda leer las
  # credenciales del rol desde el metadata endpoint.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.root_volume_encrypted
    delete_on_termination = true

    tags = merge(var.tags, { Name = "${var.name}-root" })
  }

  tags = merge(var.tags, { Name = var.name })

  lifecycle {
    # La AMI se resuelve dinamicamente a la ultima publicada por Canonical.
    # Sin esto, cada release nueva de Ubuntu marcaria la instancia para
    # reemplazo en el plan. Para actualizar el SO se hace a proposito.
    ignore_changes = [ami]
  }
}
