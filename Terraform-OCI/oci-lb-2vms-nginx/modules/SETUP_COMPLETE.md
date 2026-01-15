# ✅ CONFIGURACIÓN COMPLETADA

## 📦 Estructura de la Infraestructura

Se ha creado una infraestructura completa en OCI con:

### 🌐 Networking (módulo networking/)
- ✅ VCN con CIDR 172.17.0.0/16
- ✅ Subnet Pública (172.17.1.0/24) - Load Balancer + Bastion
- ✅ Subnet Privada (172.17.2.0/24) - Web Servers
- ✅ Internet Gateway configurado
- ✅ Route Tables para ambas subnets
- ✅ Security Lists con reglas específicas

### 💻 Compute (módulo compute/)
- ✅ 2 Web Servers preemptibles (VM.Standard.E2.1.Micro)
- ✅ 1 Bastion Host (VM.Standard.E2.1.Micro)
- ✅ Data sources para obtener imágenes y shapes
- ✅ Scripts de inicialización automática

### ⚖️ Load Balancer (módulo load_balancer/)
- ✅ Load Balancer flexible (10 Mbps - Always Free)
- ✅ Backend Set con política Round Robin
- ✅ 2 Backends (Web Servers)
- ✅ Listener HTTP en puerto 80
- ✅ Health Checker configurado

## 🔧 PASOS SIGUIENTES

### 1. ⚠️ ACTUALIZAR terraform.tfvars

**IMPORTANTE:** Debes actualizar estos valores en `terraform.tfvars`:

```hcl
# ====================================
# CAMBIAR ESTOS VALORES ↓
# ====================================

# Compartment OCID (puede ser el tenancy root)
compartment_id = "TU_COMPARTMENT_OCID_AQUI"

# SSH Public Key (genera una si no tienes)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... tu_clave_aqui"
```

#### Generar SSH Key (si no tienes una):

```bash
# En Linux/Mac:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/oci_key

# Tu clave pública estará en:
cat ~/.ssh/oci_key.pub
```

```powershell
# En Windows (PowerShell):
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\oci_key

# Ver tu clave pública:
Get-Content $env:USERPROFILE\.ssh\oci_key.pub
```

### 2. 🚀 DESPLEGAR LA INFRAESTRUCTURA

```bash
# En el directorio modules/
terraform plan
terraform apply
```

### 3. ⚙️ CONFIGURACIÓN AUTOMÁTICA EN INSTANCIAS

Las instancias se inicializan automáticamente mediante los scripts bash ubicados en `compute/scripts/`.
Estos scripts son inyectados como `user_data` y ejecutados al primer arranque de cada instancia. No es necesario usar Ansible.

Si prefieres gestionar la configuración manualmente, puedes conectarte al Bastion y ejecutar comandos sobre las instancias privadas.

### 4. 🔍 VER RESULTADOS

```bash
terraform output
```

Esto mostrará:
- IP pública del Bastion Host
- IPs privadas de los Web Servers
- IP pública del Load Balancer
- Instrucciones de conexión SSH

### 4. 🌐 PROBAR LA APLICACIÓN

Abre en tu navegador:
```
http://<LOAD_BALANCER_IP>
```

Refresca varias veces para ver el Round Robin alternando entre Web Server #1 y #2.

## 📝 ARCHIVOS IMPORTANTES

- `terraform.tfvars` - **Actualizar con tus valores**
- `README.md` - Documentación completa
- `compute/scripts/` - Scripts bash inyectados como `user_data` (`web_server_init.sh`, `bastion_init.sh`)

## 🔒 SEGURIDAD

### ⚠️ Ajustar Security Lists en Producción

En `networking/security_lists.tf`, la Security List pública permite SSH desde 0.0.0.0/0:

```hcl
# ACTUAL (permite desde cualquier IP)
ingress_security_rules {
  source = "0.0.0.0/0"
  ...
}

# RECOMENDADO (solo tu IP)
ingress_security_rules {
  source = "TU_IP_PUBLICA/32"  # Ejemplo: "203.0.113.42/32"
  ...
}
```

## 💰 COSTOS

Todo está configurado para Always Free tier:
- ✅ 2x VM.Standard.E2.1.Micro (preemptible)
- ✅ 1x VM.Standard.E2.1.Micro (bastion)
- ✅ Load Balancer flexible (10 Mbps)
- ✅ Networking (VCN, subnets, etc.)

**Total: $0/mes**

## 🧹 LIMPIAR TODO

Para destruir toda la infraestructura:

```bash
terraform destroy
```

## 📊 VERIFICAR DATA SOURCES

Los data sources configurados obtienen automáticamente:
- ✅ Compartment actual
- ✅ Availability Domains disponibles
- ✅ Imágenes de Oracle Linux 8 más recientes
- ✅ Shapes disponibles
- ✅ Load Balancer shapes disponibles
- ✅ Load Balancer policies disponibles

## 🎯 CARACTERÍSTICAS CLAVE

### Load Balancer
- **Shape**: flexible
- **Bandwidth**: 10 Mbps min/max (Always Free)
- **Política**: Round Robin
- **Health Check**: HTTP / cada 10s

### Web Servers
- **OS**: Oracle Linux 8
- **Web Server**: Nginx (instalado vía Ansible)
- **Página**: Personalizada con template Jinja2
- **Preemptible**: Sí (reduce costos)
- **Configuración**: Automatizada con Ansible

### Bastion Host
- **OS**: Oracle Linux 8
- **Propósito**: Acceso SSH a instancias privadas
- **IP Pública**: Sí (instaladas vía Ansible)
- **Configuración**: Automatizada con Ansible
- **Herramientas**: vim, wget, curl, net-tools

## 📚 ESTRUCTURA COMPLETA

```
modules/
├── main.tf                           # ← Orquestación principal
├── variables.tf                      # ← Variables globales
├── terraform.tfvars                  # ← ⚠️ ACTUALIZAR ESTE ARCHIVO
├── outputs.tf                        # ← Outputs principales
├── provides.tf                       # ← Provider OCI
├── README.md                         # ← Documentación completa
├── compute/                          # Módulo de compute
│   ├── data-sources.tf              # ← Data sources (shapes, images)
│   ├── instances.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── scripts/                     # Scripts bash inyectados como user_data
│       ├── web_server_init.sh
│       └── bastion_init.sh
│
├── networking/                       # Módulo de red
│   ├── vcn.tf
│   ├── subnets.tf
│   ├── security_lists.tf
│   ├── internet_gateways.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── compute/                          # Módulo de compute
│   ├── data-sources.tf              # ← Data sources (shapes, images)
│   ├── instances.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── scripts/                     # Scripts bash (legacy/referencia)
│       ├── web_server_init.sh
│       └── bastion_init.shr web
│       └── bastion_init.sh          # ← Script bastion
│s pasos**:
1. Actualiza `terraform.tfvars` con tu compartment OCID y SSH public key
2. Ejecuta `terraform apply` para crear la infraestructura
3. Ejecuta `cd ansible && python3 generate_inventory.py` para generar el inventario
4. Ejecuta `ansible-playbook site.yml` para configurar las instancias
5. Accede al Load Balancer en tu navegador
└── load_balancer/                   # Módulo de load balancer
    ├── data-sources.tf              # ← Data sources (shapes, policies)
    ├── load_balancer.tf
    ├── variables.tf
    └── outputs.tf
```

## ✅ TODO LISTO

La infraestructura está completamente configurada y lista para desplegar.

**Siguiente paso**: Actualiza `terraform.tfvars` con tu compartment OCID y SSH public key, luego ejecuta `terraform apply`.

¡Buena suerte! 🚀
