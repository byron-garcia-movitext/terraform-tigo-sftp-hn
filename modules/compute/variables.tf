variable "name" {
  description = "Nombre de la instancia (tag Name)."
  type        = string
}

variable "ami_id" {
  description = "AMI con la que se lanza la instancia."
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2."
  type        = string
}

variable "subnet_id" {
  description = "Subnet donde se coloca la instancia."
  type        = string
}

variable "key_name" {
  description = "Key pair existente para acceso SSH."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups asociados a la interfaz de red."
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "Asignar IP publica. En subnet privada debe quedar en false."
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Tamano del volumen raiz en GiB."
  type        = number
  default     = 80
}

variable "root_volume_type" {
  description = "Tipo de volumen EBS del disco raiz."
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Cifrar el volumen raiz con la llave EBS por default de la cuenta."
  type        = bool
  default     = true
}

variable "disable_api_termination" {
  description = "Proteccion contra terminacion accidental de la instancia."
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "Habilitar CloudWatch detailed monitoring (intervalos de 1 minuto)."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Script de arranque. Null para no enviar ninguno."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags adicionales para la instancia y sus volumenes."
  type        = map(string)
  default     = {}
}
