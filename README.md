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

El state es **local**: vive en `terraform.tfstate` dentro de esta carpeta. No hay backend remoto.

Implicaciones a tener presentes:

- **El archivo esta en `.gitignore` y no debe subirse al repo.** El state guarda en texto plano cosas
  que la API devuelve, incluidas las que en el codigo estarian marcadas como sensibles.
- **Si se pierde el `terraform.tfstate`, Terraform deja de saber que la instancia existe.** Un `apply`
  posterior intentaria crear una segunda instancia en vez de administrar la actual. Conviene respaldar
  el archivo (y su `.backup`) junto con el resto de la documentacion del proyecto.
- **No hay locking.** Mientras el state sea local, que aplique una sola persona desde una sola maquina.

Si mas adelante se decide mover a S3, en `versions.tf` esta el bloque `backend "s3"` comentado:
se descomenta y se corre `terraform init -migrate-state`.

## Pendientes

- No hay IAM instance profile. Si se quiere SSM Session Manager o Patch Manager (coherente con el tag `PatchGroup`), hay que agregarlo.
