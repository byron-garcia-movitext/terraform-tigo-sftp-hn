output "instance_id" {
  description = "ID de la instancia EC2."
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN de la instancia EC2."
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "IP privada de la instancia."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "IP publica de la instancia, si tiene."
  value       = aws_instance.this.public_ip
}

output "availability_zone" {
  description = "AZ donde quedo la instancia."
  value       = aws_instance.this.availability_zone
}

output "root_volume_id" {
  description = "ID del volumen raiz."
  value       = aws_instance.this.root_block_device[0].volume_id
}
