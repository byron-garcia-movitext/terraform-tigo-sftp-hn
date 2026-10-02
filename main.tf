###############################################################################
# SFTP-Tigo-HN
#
# Raiz del proyecto: resuelve los datos del entorno (VPC, AMI) y conecta el
# modulo de seguridad con el de computo.
###############################################################################

# La VPC se deriva de la subnet en vez de pedirse como variable, asi no hay
# forma de pasar una subnet y una VPC que no correspondan entre si.
data "aws_subnet" "this" {
  id = var.subnet_id
}

# Ultima AMI oficial de Ubuntu 24.04 LTS (Noble) publicada por Canonical.
# El owner 099720109477 es la cuenta oficial de Canonical.
data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

###############################################################################
# Seguridad
###############################################################################

module "security" {
  source = "./modules/security"

  name        = "${var.project_name}-sg"
  description = "Security group de la instancia SFTP de Tigo Honduras"
  vpc_id      = data.aws_subnet.this.vpc_id

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
}

###############################################################################
# Computo
###############################################################################

module "compute" {
  source = "./modules/compute"

  name          = var.instance_name
  ami_id        = data.aws_ami.ubuntu_2404.id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id          = var.subnet_id
  security_group_ids = [module.security.security_group_id]

  # La subnet es privada, no corresponde IP publica.
  associate_public_ip_address = false

  root_volume_size = var.root_volume_size
  root_volume_type = var.root_volume_type
}
