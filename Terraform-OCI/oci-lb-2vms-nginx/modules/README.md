# 🚀 Infraestructura OCI - Load Balancer con 2 Web Servers

Infraestructura completa en Oracle Cloud Infrastructure (OCI) con:
- **VCN** con subnets pública y privada
- **Load Balancer** con política Round Robin (Always Free tier)
- **2 Web Servers** preemptibles en subnet privada (Always Free tier)
- **1 Bastion Host** en subnet pública para acceso SSH
- **Security Lists** configuradas para máxima seguridad

## 📋 Arquitectura

```
Internet
    │
    ├── Internet Gateway
    │
    ├── Subnet Pública (172.17.1.0/24)
    │   ├── Load Balancer (flexible, 10 Mbps)
    │   └── Bastion Host (VM.Standard.E2.1.Micro)
    │
    └── Subnet Privada (172.17.2.0/24)
        ├── Web Server 1 (VM.Standard.E2.1.Micro, preemptible)
        └── Web Server 2 (VM.Standard.E2.1.Micro, preemptible)
```

## 🔧 Requisitos Previos

1. **Cuenta OCI** con acceso a Always Free tier
2. **Terraform** >= 1.0.0 instalado
3. **OCI CLI** configurado (opcional pero recomendado)
4. **Claves SSH** generadas:
   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/oci_key
   ```

## ⚙️ Configuración

### 1. Actualizar `terraform.tfvars`

Edita el archivo [`terraform.tfvars`](terraform.tfvars ) con tus valores:

```hcl
# Provider credentials
tenancy_ocid     = "ocid1.tenancy.oc1..xxxxx"
user_ocid        = "ocid1.user.oc1..xxxxx"
fingerprint      = "xx:xx:xx:xx:..."
private_key_path = "C:/Users/User/.oci/oci_api_key.pem"
region           = "sa-bogota-1"

# Compartment (puede ser el tenancy root)
compartment_id = "ocid1.compartment.oc1..xxxxx"

# SSH Public Key
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
```

### 2. Variables Configurables

Todas las variables tienen valores por defecto razonables. Puedes ajustar en [`variables.tf`](variables.tf ):

- **Networking**: CIDRs de VCN y subnets
- **Compute**: Shapes de instancias (Always Free tier)
- **Load Balancer**: Ancho de banda (10 Mbps para Always Free)

## 🚀 Despliegue

### 1. Inicializar Terraform

```bash
cd modules
terraform init
```

### 2. Revisar Plan

```bash
terraform plan
```

### 3. Aplicar Infraestructura

```bash
terraform apply
```

⏱️ **Tiempo estimado**: 10-15 minutos

### 4. Configuración automática en instancias

Los servidores se inicializan automáticamente usando los scripts bash ubicados en `compute/scripts/`.
Estos scripts son inyectados como `user_data` en las instancias y realizan:
- Actualización del sistema
- Instalación y configuración de Nginx (web servers)
- Configuración del Bastion (herramientas y firewall)

No es necesario ejecutar Ansible; la configuración se aplica al primer arranque.

## 🔐 Acceso SSH

Después del despliegue, Terraform mostrará las instrucciones de conexión:

### 1. Conectar al Bastion Host

```bash
ssh -i ~/.ssh/oci_key opc@<BASTION_PUBLIC_IP>
```

### 2. Desde el Bastion, conectar a Web Servers

```bash
# Web Server 1
ssh -i ~/.ssh/oci_key opc@<WEB_SERVER_1_PRIVATE_IP>

# Web Server 2
ssh -i ~/.ssh/oci_key opc@<WEB_SERVER_2_PRIVATE_IP>
```

### 3. Acceder a la Aplicación Web

Abre en tu navegador:
```
http://<LOAD_BALANCER_PUBLIC_IP>
```

La página web mostrará información de la instancia que está respondiendo. Refresca varias veces para ver el Round Robin en acción.

## 📊 Verificación

### Ver Outputs

```bash
terraform output
```

### Verificar Load Balancer

```bash
# Ver respuestas de diferentes servidores
for i in {1..10}; do
  curl http://<LOAD_BALANCER_IP>
  echo "---"
done
```

### Verificar Health Check

En la consola OCI:
1. **Networking** → **Load Balancers**
2. Selecciona tu load balancer
3. Ve a **Backend Sets** → **Backends**
4. Verifica que ambos backends estén **HEALTHY**

## 🏗️ Estructura del Proyecto

```
modules/
├── main.tf                    # Orquestación principal
├── variables.tf               # Variables globales
├── terraform.tfvars           # Valores de variables
├── outputs.tf                 # Outputs principales
├── provides.tf                # Provider configuration
├── README.md                  # Este archivo
│
├── compute/                   # Módulo de compute
│   ├── data-sources.tf       # Data sources (shapes, images)
│   ├── instances.tf          # Web servers y Bastion (user_data scripts)
│   ├── variables.tf
│   ├── outputs.tf
│   └── scripts/              # Scripts bash inyectados como user_data
│       ├── web_server_init.sh
│       └── bastion_init.sh
│
├── networking/                # Módulo de red
│   ├── vcn.tf                # VCN
│   ├── subnets.tf            # Subnets y Route Tables
│   ├── security_lists.tf     # Security Lists
│   ├── internet_gateways.tf  # Internet Gateway
│   ├── variables.tf
│   └── outputs.tf
│
├── compute/                   # Módulo de compute
│   ├── data-sources.tf       # Data sources (shapes, images)
│   ├── instances.tf          # Web servers y Bastion
│   ├── variables.tf
│   ├── outputs.tf
│   └── scripts/              # Scripts bash (legacy/referencia)
│       ├── web_server_init.sh
│       └── bastion_init.sh
│
└── load_balancer/            # Módulo de load balancer
    ├── data-sources.tf       # Data sources (shapes, policies)
    ├── load_balancer.tf      # LB, Backend Set, Listener
    ├── variables.tf
    └── outputs.tf
```

## 🔒 Security Lists

### Subnet Pública
- **Ingress**:
  - HTTP (80) desde 0.0.0.0/0 (Load Balancer)
  - SSH (22) desde 0.0.0.0/0 (Bastion) ⚠️ *En producción, limitar a IPs específicas*
  - Todo el tráfico desde VCN
- **Egress**: Todo permitido

### Subnet Privada
- **Ingress**:
  - HTTP (80) solo desde subnet pública
  - SSH (22) solo desde subnet pública
  - Todo el tráfico desde VCN
- **Egress**: Todo permitido

## 💰 Costos (Always Free Tier)

- ✅ **2x VM.Standard.E2.1.Micro** (preemptible): GRATIS
- ✅ **1x VM.Standard.E2.1.Micro** (bastion): GRATIS
- ✅ **Load Balancer flexible** (10 Mbps): GRATIS
- ✅ **VCN, Subnets, Security Lists**: GRATIS

**Total: $0/mes** (dentro del Always Free tier)

## 🧹 Limpieza

Para destruir toda la infraestructura:

```bash
terraform destroy
```

Confirma escribiendo `yes` cuando se solicite.

## 📝 Características del Web Server

Cada web server se configura automáticamente con Ansible:
- **Nginx** como servidor web
- **Página HTML personalizada** con información dinámica:
  - Número de servidor (#1 o #2)
  - Hostname
  - IP privada
  - Información del sistema (OS, RAM, CPU)
  - Instance metadata de OCI
- **Firewall configurado** (puertos 80 y 22)
- **SELinux** configurado correctamente

## 🔄 Load Balancer - Política Round Robin

- **Distribución**: Equitativa entre los 2 servidores
- **Health Check**: Cada 10 segundos
- **Timeout**: 3 segundos
- **Retries**: 3 intentos antes de marcar como unhealthy
- **Expected Response**: HTTP 200 OK

## 🐛 Troubleshooting

### Load Balancer no responde

1. Verifica que los backends estén HEALTHY en la consola OCI
2. Revisa los Security Lists de ambas subnets
3. Verifica que nginx esté corriendo en los web servers:
   ```bash
   ssh opc@<bastion_ip>
   ssh opc@<web_server_ip>
   sudo systemctl status nginx
   ```

### No puedo acceder al Bastion

1. Verifica que la Security List permite SSH desde tu IP
2. Verifica que estás usando la clave SSH correcta
3. Revisa que el Bastion tenga IP pública asignada

### Web Servers no responden al Health Check

1. Conéctate al web server vía bastion
2. Verifica nginx:
   ```bash
   sudo systemctl status nginx
   sudo journalctl -u nginx -f
   ```
3. Verifica firewall:
   ```bash
   sudo firewall-cmd --list-all
   ```

## 📚 Referencias

- [OCI Terraform Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [OCI Always Free Tier](https://www.oracle.com/cloud/free/)
- [OCI Load Balancing](https://docs.oracle.com/en-us/iaas/Content/Balance/Concepts/balanceoverview.htm)

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

---

**¡Disfruta de tu infraestructura en OCI! 🎉**
