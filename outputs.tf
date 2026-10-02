output "instance_id" {
  description = "ID de la instancia SFTP-Tigo-HN."
  value       = module.compute.instance_id
}

output "instance_private_ip" {
  description = "IP privada de la instancia."
  value       = module.compute.private_ip
}

output "instance_availability_zone" {
  description = "AZ donde quedo la instancia."
  value       = module.compute.availability_zone
}

output "security_group_id" {
  description = "ID del security group asociado."
  value       = module.security.security_group_id
}

output "ami_id" {
  description = "AMI de Ubuntu 24.04 con la que se lanzo la instancia."
  value       = data.aws_ami.ubuntu_2404.id
}

output "vpc_id" {
  description = "VPC derivada de la subnet."
  value       = data.aws_subnet.this.vpc_id
}
