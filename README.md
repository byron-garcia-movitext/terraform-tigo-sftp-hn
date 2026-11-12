# terraform-sftp-tigo-hn

Infraestructura de la instancia **SFTP-Tigo-HN** en AWS (cuenta `883347190686`, region `us-east-1`).

## Estructura

```
.
├── main.tf              # Data sources del entorno + wiring de los modulos
├── variables.tf         # Variables de entrada del root
├── outputs.tf           # Salidas del stack
├── providers.tf         # Provider AWS + default_tags
├── versions.tf          # Pins de Terraform y provider, backend
├── terraform.tfvars     # Valores concretos de este despliegue
└── modules/
    ├── security/        # Security group y sus reglas
    └── compute/         # Instancia EC2 y su volumen raiz
```

## Que crea

| Recurso | Valor |
|---|---|
| Instancia EC2 | `SFTP-Tigo-HN`, `t3.small`, Ubuntu 24.04 LTS |
| Subnet | `subnet-0b69fb7426d20b41a` (`sbnt-prod-use1a-priv-tools-dev`, us-east-1a) |
| VPC | `vpc-44989921` (derivada de la subnet) |
| Key pair | `kp-sftp-tigo-hn` (preexistente, no lo gestiona Terraform) |
| Disco raiz | 80 GiB gp3, cifrado |
| Security group | `sftp-tigo-hn-sg` |

### Reglas del security group

**Ingress**

| Origen | Protocolo | Puertos |
|---|---|---|
| `192.168.252.0/24` | All traffic | All |

**Egress**

| Destino | Protocolo | Puertos |
|---|---|---|
| `0.0.0.0/0` | All traffic | All |

## Tags

Se aplican via `default_tags` del provider, por lo que alcanzan a todo recurso que los soporte:

```
CreatedBy   = byron.miranda
Product     = SFTP-TIGO
PatchGroup  = Production
Environment = Production
Customer    = Tigo-HN
Team        = Infra-Team
Criticality = Medium
ManagedBy   = Terraform
Repository  = terraform-sftp-tigo-hn
```

El tag `Name` lo pone cada recurso por separado (`SFTP-Tigo-HN` para la instancia).

## Uso

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Decisiones de diseno

- **La VPC no es una variable.** Se deriva de la subnet con `data "aws_subnet"`, asi no hay forma de pasar una subnet y una VPC que no correspondan.
- **AMI dinamica.** Se resuelve la ultima Ubuntu 24.04 publicada por Canonical (owner `099720109477`). La instancia tiene `ignore_changes = [ami]` para que una release nueva de Ubuntu no marque la instancia para reemplazo; actualizar el SO es una accion deliberada.
- **Reglas de SG como recursos separados** (`aws_vpc_security_group_ingress_rule`) en vez de bloques inline: cada regla tiene su id en el state y se puede tocar sin recrear el grupo.
- **La llave del mapa de reglas es el identificador.** Cambiar `red-corporativa` por otro nombre recrea esa regla. Para agregar reglas (ej. SFTP desde otra red) se agrega una entrada nueva al mapa en `terraform.tfvars`.
- **IMDSv2 obligatorio** y **volumen raiz cifrado** por default en el modulo de computo.
- **`disable_api_termination = true`**: para destruir la instancia hay que bajarlo primero a `false` y aplicar.

## State

El state esta en S3 (`movi-terraform-s3/sftp-tigo-hn/terraform.tfstate`), ver `backend.tf` y la seccion
**State remoto (S3)** al final. Sigue sin subirse al repo: guarda en texto plano cosas que la API
devuelve, incluidas las marcadas como sensibles.

## Pendientes

- No hay IAM instance profile. Si se quiere SSM Session Manager o Patch Manager (coherente con el tag `PatchGroup`), hay que agregarlo.


## State remoto (S3)

El state de Terraform **no se guarda en git**. Vive en S3:

| | |
|---|---|
| Bucket | `movi-terraform-s3` (us-east-1, cifrado SSE) |
| Key | `sftp-tigo-hn/terraform.tfstate` |
| Locking | nativo de S3 (`use_lockfile = true`), sin DynamoDB |

La configuración está en `backend.tf`. Para trabajar con el proyecto:

```bash
git clone <repo> && cd <repo>
terraform init        # descarga el state desde S3 automáticamente
terraform plan
```

Requisitos: Terraform >= 1.10 y credenciales AWS con permiso `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` y `s3:ListBucket` sobre `movi-terraform-s3/sftp-tigo-hn/*`.
No copies ni subas `terraform.tfstate` a mano: si `terraform init` pregunta por migrar un state local, cancela y revisa.
