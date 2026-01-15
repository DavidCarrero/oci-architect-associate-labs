# 🏗️ ARQUITECTURA DE LA INFRAESTRUCTURA

## 📊 Diagrama de Red

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ORACLE CLOUD REGION                             │
│                           (sa-bogota-1)                                 │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │                    VCN: 172.17.0.0/16                             │ │
│  │                    vcn-lb-webservers                              │ │
│  │                                                                   │ │
│  │  ┌─────────────────────────────────────────────────────────┐    │ │
│  │  │          Internet Gateway (igw-main)                     │    │ │
│  │  └─────────────────────────────────────────────────────────┘    │ │
│  │                          │                                        │ │
│  │          ┌───────────────┴───────────────┐                       │ │
│  │          │                               │                       │ │
│  │  ┌───────▼──────────────┐    ┌──────────▼──────────────┐        │ │
│  │  │  SUBNET PÚBLICA      │    │  SUBNET PRIVADA         │        │ │
│  │  │  172.17.1.0/24       │    │  172.17.2.0/24          │        │ │
│  │  │  subnet-public       │    │  subnet-private         │        │ │
│  │  │                      │    │                         │        │ │
│  │  │  ┌────────────────┐  │    │  ┌───────────────────┐ │        │ │
│  │  │  │ Load Balancer  │  │    │  │  Web Server 1     │ │        │ │
│  │  │  │ lb-web-servers │  │    │  │  web-server-1     │ │        │ │
│  │  │  │                │  │    │  │                   │ │        │ │
│  │  │  │ Shape: flexible│◄─┼────┼──┤ Shape: E2.1.Micro │ │        │ │
│  │  │  │ BW: 10 Mbps    │  │    │  │ IP: 172.17.2.x    │ │        │ │
│  │  │  │ Policy: RR     │  │    │  │ Preemptible: Yes  │ │        │ │
│  │  │  │ IP: Public     │  │    │  │ Nginx: Port 80    │ │        │ │
│  │  │  └────────────────┘  │    │  └───────────────────┘ │        │ │
│  │  │          │            │    │           │            │        │ │
│  │  │  ┌───────▼─────────┐ │    │  ┌────────▼──────────┐ │        │ │
│  │  │  │  Bastion Host   │ │    │  │  Web Server 2     │ │        │ │
│  │  │  │  bastion-host   │ │    │  │  web-server-2     │ │        │ │
│  │  │  │                 │ │    │  │                   │ │        │ │
│  │  │  │ Shape: E2.1.Micro│ │   │  │ Shape: E2.1.Micro │ │        │ │
│  │  │  │ IP: Public      │─┼────┼──┤ IP: 172.17.2.x    │ │        │ │
│  │  │  │ SSH: Port 22    │ │    │  │ Preemptible: Yes  │ │        │ │
│  │  │  └─────────────────┘ │    │  │ Nginx: Port 80    │ │        │ │
│  │  │                      │    │  └───────────────────┘ │        │ │
│  │  └──────────────────────┘    └─────────────────────────┘        │ │
│  │                                                                   │ │
│  └───────────────────────────────────────────────────────────────────┘ │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
                                  │
                          ┌───────▼────────┐
                          │    INTERNET    │
                          │                │
                          │  Usuario final │
                          └────────────────┘
```

## 🔄 Flujo de Tráfico

### 1. Acceso Web (HTTP)
```
Usuario → Internet → Load Balancer (IP Pública, Puerto 80)
                      ↓ (Round Robin)
                      ├─→ Web Server 1 (IP Privada, Puerto 80)
                      └─→ Web Server 2 (IP Privada, Puerto 80)
```

### 2. Acceso SSH
```
Usuario → Internet → Bastion Host (IP Pública, Puerto 22)
                      ↓ (SSH interno)
                      ├─→ Web Server 1 (IP Privada, Puerto 22)
                      └─→ Web Server 2 (IP Privada, Puerto 22)
```

## 🔒 Security Lists

### Subnet Pública (Load Balancer + Bastion)

**INGRESS:**
```
┌────────────┬────────┬──────────┬──────────────────────┐
│ Protocolo  │ Puerto │ Origen   │ Descripción          │
├────────────┼────────┼──────────┼──────────────────────┤
│ TCP        │ 80     │ 0.0.0.0/0│ HTTP → Load Balancer │
│ TCP        │ 22     │ 0.0.0.0/0│ SSH → Bastion        │
│ ALL        │ ALL    │ VCN CIDR │ Tráfico interno VCN  │
│ ICMP       │ -      │ 0.0.0.0/0│ Ping (diagnóstico)   │
└────────────┴────────┴──────────┴──────────────────────┘
```

**EGRESS:**
```
┌────────────┬──────────┬──────────────────────┐
│ Protocolo  │ Destino  │ Descripción          │
├────────────┼──────────┼──────────────────────┤
│ ALL        │ 0.0.0.0/0│ Todo permitido       │
└────────────┴──────────┴──────────────────────┘
```

### Subnet Privada (Web Servers)

**INGRESS:**
```
┌────────────┬────────┬──────────────┬───────────────────────┐
│ Protocolo  │ Puerto │ Origen       │ Descripción           │
├────────────┼────────┼──────────────┼───────────────────────┤
│ TCP        │ 80     │ 172.17.1.0/24│ HTTP desde LB         │
│ TCP        │ 22     │ 172.17.1.0/24│ SSH desde Bastion     │
│ ALL        │ ALL    │ VCN CIDR     │ Tráfico interno VCN   │
│ ICMP       │ -      │ VCN CIDR     │ Ping desde VCN        │
└────────────┴────────┴──────────────┴───────────────────────┘
```

**EGRESS:**
```
┌────────────┬──────────┬──────────────────────┐
│ Protocolo  │ Destino  │ Descripción          │
├────────────┼──────────┼──────────────────────┤
│ ALL        │ 0.0.0.0/0│ Todo permitido       │
└────────────┴──────────┴──────────────────────┘
```

## 🎯 Load Balancer - Backend Set

### Configuración
```
Backend Set: backend-web-servers
├─ Política: ROUND_ROBIN
├─ Health Check:
│  ├─ Protocolo: HTTP
│  ├─ Puerto: 80
│  ├─ Path: /
│  ├─ Intervalo: 10 segundos
│  ├─ Timeout: 3 segundos
│  ├─ Retries: 3
│  └─ Expected: 200 OK
│
└─ Backends:
   ├─ Web Server 1 (172.17.2.x:80) Weight: 1
   └─ Web Server 2 (172.17.2.x:80) Weight: 1
```

### Round Robin Distribution
```
Request 1 → Web Server 1
Request 2 → Web Server 2
Request 3 → Web Server 1
Request 4 → Web Server 2
Request 5 → Web Server 1
...
```

## 💻 Instancias de Compute

### Web Server 1 & 2
```yaml
Nombre: web-server-1, web-server-2
Shape: VM.Standard.E2.1.Micro
  CPU: 1 core (ARM-based Ampere A1)
  RAM: 1 GB
  Boot Volume: 46.6 GB
OS: Oracle Linux 8
Network: 
  - Subnet: subnet-private (172.17.2.0/24)
  - IP Privada: Asignada automáticamente
  - IP Pública: NO
Preemptible: YES
Software:
  - Nginx (instalado automáticamente)
  - Página web personalizada
  - Firewall configurado (puerto 80 abierto)
```

### Bastion Host
```yaml
Nombre: bastion-host
Shape: VM.Standard.E2.1.Micro
  CPU: 1 core (ARM-based Ampere A1)
  RAM: 1 GB
  Boot Volume: 46.6 GB
OS: Oracle Linux 8
Network:
  - Subnet: subnet-public (172.17.1.0/24)
  - IP Privada: Asignada automáticamente
  - IP Pública: SÍ
Preemptible: NO
Software:
  - SSH Server
  - Herramientas: vim, wget, curl, net-tools
  - Mensaje de bienvenida personalizado
```

## 📁 Módulos de Terraform

```
main.tf
├─ Data Sources Globales
│  ├─ oci_identity_compartment.current
│  ├─ oci_identity_availability_domains.ads
│  └─ oci_core_images.oracle_linux
│
├─ Module: networking
│  ├─ VCN (oci_core_vcn.main)
│  ├─ Subnets (oci_core_subnet.public/private)
│  ├─ Route Tables (oci_core_route_table.public/private)
│  ├─ Security Lists (oci_core_security_list.public/private)
│  └─ Internet Gateway (oci_core_internet_gateway.main)
│
├─ Module: compute
│  ├─ Data Sources
│  │  ├─ oci_identity_availability_domains.ads
│  │  ├─ oci_core_images.oracle_linux
│  │  └─ oci_core_shapes.available_shapes
│  ├─ Web Servers (oci_core_instance.web_servers[0..1])
│  └─ Bastion (oci_core_instance.bastion)
│
└─ Module: load_balancer
   ├─ Data Sources
   │  ├─ oci_load_balancer_shapes.available
   │  └─ oci_load_balancer_policies.available
   ├─ Load Balancer (oci_load_balancer_load_balancer.main)
   ├─ Backend Set (oci_load_balancer_backend_set.main)
   ├─ Backends (oci_load_balancer_backend.web_servers[0..1])
   └─ Listener (oci_load_balancer_listener.http)
```

## 🚀 Proceso de Despliegue

```
1. terraform init
   └─> Descarga provider oracle/oci
   └─> Inicializa módulos locales

2. terraform plan
   └─> Calcula cambios
   └─> Muestra recursos a crear:
       ├─ 1 VCN
       ├─ 2 Subnets
       ├─ 2 Route Tables
       ├─ 2 Security Lists
       ├─ 1 Internet Gateway
       ├─ 3 Instancias (2 web + 1 bastion)
       ├─ 1 Load Balancer
       ├─ 1 Backend Set
       ├─ 2 Backends
       └─ 1 Listener
       Total: ~15-20 recursos

3. terraform apply
   └─> Crea recursos en orden de dependencias:
       1. VCN
       2. Internet Gateway
       3. Subnets
       4. Route Tables
       5. Security Lists
       6. Instancias
       7. Load Balancer
       8. Backend Set
       9. Backends
       10. Listener
   └─> Tiempo estimado: 10-15 minutos

4. terraform output
   └─> Muestra IPs y comandos SSH
```

## 💡 Características Destacadas

### ✅ Always Free Tier Compatible
- Usa solo recursos del Always Free tier
- 2 instancias micro preemptibles
- Load Balancer con mínimo bandwidth (10 Mbps)
- Costo: $0/mes

### ✅ Alta Disponibilidad
- 2 web servers en diferentes IPs
- Health checks automáticos
- Failover automático si un servidor falla

### ✅ Seguridad
- Web servers sin IP pública
- Bastion como único punto de entrada SSH
- Security Lists restrictivas
- Tráfico interno en red privada

### ✅ Automatización Completa
- Scripts de inicialización automáticos
- Instalación de software sin intervención
- Configuración de firewall automática
- Página web lista al crear la instancia

### ✅ Monitoreo
- Health checks cada 10 segundos
- Logs de acceso en nginx
- Logs de SSH en bastion
- Métricas en consola OCI

## 📊 Outputs Disponibles

```hcl
# Networking
vcn_id
vcn_cidr_block
public_subnet_id
private_subnet_id

# Compute
web_server_1_private_ip
web_server_2_private_ip
web_server_ids
bastion_public_ip
bastion_id

# Load Balancer
load_balancer_id
load_balancer_public_ip
load_balancer_url

# Instrucciones
ssh_connection_instructions
```

---

**🎉 ¡Infraestructura lista para desplegar!**
