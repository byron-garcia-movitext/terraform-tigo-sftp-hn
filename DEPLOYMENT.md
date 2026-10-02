# Acta de despliegue — SFTP-Tigo-HN

Registro del despliegue inicial de la infraestructura de **SFTP-Tigo-HN**.

| | |
|---|---|
| **Fecha de despliegue** | 2026-10-02 15:59:43 UTC |
| **Ejecutado por** | `byron.miranda` (`arn:aws:iam::883347190686:user/byron.miranda`) |
| **Cuenta AWS** | `883347190686` |
| **Region** | `us-east-1` |
| **Terraform** | 1.16.1 |
| **Provider AWS** | 5.100.0 |
| **Resultado** | `Apply complete! Resources: 4 added, 0 changed, 0 destroyed.` |

---

## Recursos creados

### Instancia EC2

| Atributo | Valor |
|---|---|
| Instance ID | `i-00325d9016a7e0e59` |
| Name | `SFTP-Tigo-HN` |
| Tipo | `t3.small` (2 vCPU / 2 GiB) |
| AMI | `ami-0045d7fc2ad003464` — Ubuntu 24.04 LTS (Noble), Canonical |
| Estado | `running` |
| Availability Zone | `us-east-1a` |
| IP privada | `172.31.81.215` |
| DNS privado | `ip-172-31-81-215.ec2.internal` |
| IP publica | ninguna (subnet privada) |
| Key pair | `kp-sftp-tigo-hn` (ed25519, preexistente) |
| IAM instance profile | ninguno |
| Proteccion de terminacion | habilitada |
| IMDS | v2 obligatorio (`http_tokens = required`) |

### Almacenamiento

| Atributo | Valor |
|---|---|
| Volume ID | `vol-03c8f137b9d02bfc8` |
| Dispositivo | `/dev/sda1` (raiz) |
| Tamano | 80 GiB |
| Tipo | `gp3` |
| Cifrado | si (llave EBS por default de la cuenta) |
| Borrado al terminar | si |

No hay volumen de datos separado: los archivos del SFTP viven en el mismo disco raiz.

### Red

| Atributo | Valor |
|---|---|
| VPC | `vpc-44989921` |
| Subnet | `subnet-0b69fb7426d20b41a` |
| Nombre de la subnet | `sbnt-prod-use1a-priv-tools-dev` |
| CIDR de la subnet | `172.31.81.0/24` |
| Tipo | privada (`MapPublicIpOnLaunch = false`) |

La VPC no se declara como variable: se deriva de la subnet con un `data "aws_subnet"`, de modo que no es posible pasar una subnet y una VPC que no correspondan entre si.

### Security Group

| Atributo | Valor |
|---|---|
| Group ID | `sg-0cb3642da63626b7a` |
| Nombre | `sftp-tigo-hn-sg` |
| Descripcion | Security group de la instancia SFTP de Tigo Honduras |

**Ingress**

| Rule ID | Origen | Protocolo | Puertos | Descripcion |
|---|---|---|---|---|
| `sgr-0730f012124d9ba5f` | `192.168.252.0/24` | All (`-1`) | All | All traffic desde la red corporativa |

**Egress**

| Rule ID | Destino | Protocolo | Puertos | Descripcion |
|---|---|---|---|---|
| `sgr-0d32e31251dfa9870` | `0.0.0.0/0` | All (`-1`) | All | All traffic de salida |

---

## Tags aplicados

Verificados sobre la instancia. Se aplican via `default_tags` del provider, por lo que alcanzan tambien al security group y a sus reglas; `Name` lo define cada recurso por separado.

| Tag | Valor |
|---|---|
| `Name` | `SFTP-Tigo-HN` |
| `CreatedBy` | `byron.miranda` |
| `Product` | `SFTP-TIGO` |
| `PatchGroup` | `Production` |
| `Environment` | `Production` |
| `Customer` | `Tigo-HN` |
| `Team` | `Infra-Team` |
| `Criticality` | `Medium` |
| `ManagedBy` | `Terraform` |
| `Repository` | `terraform-sftp-tigo-hn` |

---

## Verificacion post-despliegue

Lo siguiente se comprobo consultando la API de AWS despues del `apply`, no leyendo el output de Terraform:

| Comprobacion | Resultado |
|---|---|
| Estado de la instancia | `running` |
| Tipo, AZ e IP privada | coinciden con lo planificado |
| Ausencia de IP publica | confirmada (`PublicIpAddress = null`) |
| Key pair asociado | `kp-sftp-tigo-hn` |
| Security group asociado | `sftp-tigo-hn-sg` |
| IMDSv2 | `required` |
| Proteccion de terminacion | `True` |
| Volumen raiz | 80 GiB, `gp3`, `Encrypted = true`, `in-use` |
| Reglas del SG | las dos esperadas, sin reglas extra |
| Tags | los 10 presentes y correctos |

Comandos usados:

```bash
aws ec2 describe-instances --instance-ids i-00325d9016a7e0e59
aws ec2 describe-volumes --filters "Name=attachment.instance-id,Values=i-00325d9016a7e0e59"
aws ec2 describe-security-group-rules --filters "Name=group-id,Values=sg-0cb3642da63626b7a"
aws ec2 describe-instance-attribute --instance-id i-00325d9016a7e0e59 --attribute disableApiTermination
```

---

## Acceso

La instancia esta en subnet privada y **no tiene IP publica**. Para llegarle por SSH hay que tener ruta hacia `172.31.81.0/24` desde la red `192.168.252.0/24` (VPN o Direct Connect), o pasar por un bastion.

```bash
ssh -i kp-sftp-tigo-hn ubuntu@172.31.81.215
```

El usuario por default de la AMI de Ubuntu es `ubuntu`. La llave privada **no esta en este repositorio** ni debe estarlo.

---

## Estado pendiente

Lo que quedo creado es la infraestructura, no el servicio.

- **El servicio SFTP todavia no esta configurado.** La instancia corre Ubuntu 24.04 limpio: no hay usuarios SFTP, ni chroot, ni directorios, ni hardening de `sshd`. Conviene hacerlo via `user_data` para que quede versionado, teniendo en cuenta que `user_data` solo corre en el primer arranque: aplicarlo ahora implicaria recrear la instancia.
- **No hay IAM instance profile.** Sin el, el tag `PatchGroup: Production` es decorativo: Patch Manager no puede actuar sobre la instancia y tampoco se puede entrar por SSM Session Manager.
- **Sin backups del volumen.** No hay politica de snapshots configurada sobre `vol-03c8f137b9d02bfc8`.
- **Sin monitoreo.** `detailed monitoring` esta deshabilitado y no hay alarmas de CloudWatch.

## Estado de Terraform

El state es **local** (`terraform.tfstate`, excluido del repositorio por `.gitignore`). No hay backend remoto ni locking.

Si se pierde ese archivo, Terraform deja de saber que estos recursos existen y un `apply` posterior intentaria crear una segunda instancia en lugar de administrar la actual. Debe respaldarse fuera del repositorio.
