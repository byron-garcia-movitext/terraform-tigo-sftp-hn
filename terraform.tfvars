aws_region   = "us-east-1"
project_name = "sftp-tigo-hn"

###############################################################################
# Computo
###############################################################################

instance_name    = "SFTP-Tigo-HN"
instance_type    = "t3.small"
key_name         = "kp-sftp-tigo-hn"
root_volume_size = 80
root_volume_type = "gp3"

# sbnt-prod-use1a-priv-tools-dev | vpc-44989921 | us-east-1a | 172.31.81.0/24
subnet_id = "subnet-0b69fb7426d20b41a"

###############################################################################
# Seguridad
###############################################################################

ingress_rules = {
  red-corporativa = {
    description = "All traffic desde la red corporativa"
    cidr_ipv4   = "192.168.252.0/24"
    ip_protocol = "-1"
  }
}

egress_rules = {
  salida-total = {
    description = "All traffic de salida"
    cidr_ipv4   = "0.0.0.0/0"
    ip_protocol = "-1"
  }
}
