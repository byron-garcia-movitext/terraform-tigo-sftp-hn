variable "name" {
  description = "Nombre del security group."
  type        = string
}

variable "description" {
  description = "Descripcion del security group."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC donde se crea el security group."
  type        = string
}

variable "ingress_rules" {
  description = <<-EOT
    Reglas de entrada. La llave del mapa es un identificador estable: cambiarla
    recrea la regla, por eso conviene que sea descriptiva y no un indice.
    ip_protocol = "-1" significa todo el trafico; en ese caso from_port/to_port
    deben omitirse.
  EOT
  type = map(object({
    description = string
    cidr_ipv4   = string
    ip_protocol = string
    from_port   = optional(number)
    to_port     = optional(number)
  }))
  default = {}
}

variable "egress_rules" {
  description = "Reglas de salida. Mismo formato que ingress_rules."
  type = map(object({
    description = string
    cidr_ipv4   = string
    ip_protocol = string
    from_port   = optional(number)
    to_port     = optional(number)
  }))
  default = {}
}

variable "tags" {
  description = "Tags adicionales para el security group."
  type        = map(string)
  default     = {}
}
