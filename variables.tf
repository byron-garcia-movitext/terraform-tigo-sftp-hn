###############################################################################
# Generales
###############################################################################

variable "aws_region" {
  description = "Region de AWS donde se despliega el proyecto."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre base del proyecto, usado como prefijo en los recursos."
  type        = string
  default     = "sftp-tigo-hn"
}

variable "common_tags" {
  description = "Tags aplicados por default a todos los recursos del proyecto."
  type        = map(string)
  default = {
    CreatedBy   = "byron.miranda"
    Product     = "SFTP-TIGO"
    PatchGroup  = "Production"
    Environment = "Production"
    Customer    = "Tigo-HN"
    Team        = "Infra-Team"
    Criticality = "Medium"
    ManagedBy   = "Terraform"
    Repository  = "terraform-sftp-tigo-hn"
  }
}

###############################################################################
# Red
###############################################################################

variable "subnet_id" {
  description = "Subnet donde se levanta la instancia EC2."
  type        = string
}

###############################################################################
# Computo
###############################################################################

variable "instance_name" {
  description = "Valor del tag Name de la instancia EC2."
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2."
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Nombre del key pair existente para acceso SSH."
  type        = string
}

variable "root_volume_size" {
  description = "Tamano del volumen raiz en GiB."
  type        = number
  default     = 80
}

variable "root_volume_type" {
  description = "Tipo de volumen EBS para el disco raiz."
  type        = string
  default     = "gp3"
}

###############################################################################
# Seguridad
###############################################################################

variable "ingress_rules" {
  description = "Reglas de entrada del security group."
  type = map(object({
    description = string
    cidr_ipv4   = string
    ip_protocol = string
    from_port   = optional(number)
    to_port     = optional(number)
  }))
}

variable "egress_rules" {
  description = "Reglas de salida del security group."
  type = map(object({
    description = string
    cidr_ipv4   = string
    ip_protocol = string
    from_port   = optional(number)
    to_port     = optional(number)
  }))
}
