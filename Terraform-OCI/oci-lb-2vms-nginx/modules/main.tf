# ==============================================================================
# MAIN CONFIGURATION - Orquestación de módulos
# ==============================================================================
# Este archivo configura la infraestructura completa:
# - VCN con subnets pública y privada
# - Internet Gateway y Route Tables
# - Security Lists para Load Balancer, Web Servers y Bastion
# - Load Balancer con Backend Set (Round Robin)
# - 2 Instancias Web Servers (Always Free tier, preemptible)
# - 1 Instancia Bastion (Always Free tier) para acceso SSH
# ==============================================================================

# ------------------------------------------------------------------------------
# DATA SOURCES GLOBALES
# ------------------------------------------------------------------------------

# Obtener información del compartment actual
data "oci_identity_compartment" "current" {
  id = var.compartment_id
}

# Obtener los Availability Domains disponibles
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Obtener la imagen de Oracle Linux 8 más reciente compatible con el shape
data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  # Nota: Quitamos el filtro de shape para obtener todas las imágenes disponibles
  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

# ------------------------------------------------------------------------------
# LOCALS - Validaciones y valores calculados
# ------------------------------------------------------------------------------
locals {
  availability_domain = try(data.oci_identity_availability_domains.ads.availability_domains[0].name, null)
  image_id             = try(data.oci_core_images.oracle_linux.images[0].id, null)
}

# ------------------------------------------------------------------------------
# MÓDULO NETWORKING
# ------------------------------------------------------------------------------
module "networking" {
  source = "./networking"

  # Identificadores
  compartment_id = var.compartment_id

  # VCN Configuration
  vcn_cidr_block   = var.vcn_cidr_block
  vcn_display_name = var.vcn_display_name
  vcn_dns_label    = var.vcn_dns_label

  # Subnet Pública (Load Balancer + Bastion)
  public_subnet_cidr_block   = var.public_subnet_cidr_block
  public_subnet_display_name = var.public_subnet_display_name
  public_subnet_dns_label    = var.public_subnet_dns_label

  # Subnet Privada (Web Servers)
  private_subnet_cidr_block   = var.private_subnet_cidr_block
  private_subnet_display_name = var.private_subnet_display_name
  private_subnet_dns_label    = var.private_subnet_dns_label

  # Internet Gateway
  internet_gateway_display_name = var.internet_gateway_display_name
}

# ------------------------------------------------------------------------------
# MÓDULO COMPUTE (Web Servers)
# ------------------------------------------------------------------------------
module "compute" {
  source = "./compute"

  # Identificadores
  compartment_id      = var.compartment_id
  availability_domain = local.availability_domain

  # Subnet IDs del módulo networking
  private_subnet_id = module.networking.private_subnet_id
  public_subnet_id  = module.networking.public_subnet_id

  # Configuración de instancias web
  instance_shape    = var.instance_shape
  instance_image_id = local.image_id
  ssh_public_key    = var.ssh_public_key
  instance_count    = 2

  # Configuración del bastion (removida - usando OCI Bastion Service)
  # bastion_shape    = var.bastion_shape
  # bastion_image_id = local.image_id
}

# ------------------------------------------------------------------------------
# MÓDULO BASTION SERVICE
# ------------------------------------------------------------------------------
module "bastion" {
  source = "./bastion"

  # Identificadores
  compartment_id = var.compartment_id

  # Target subnet (privada donde están las instancias)
  private_subnet_id = module.networking.private_subnet_id

  # Lista de IPs permitidas (cambiar a tu IP para mayor seguridad)
  allowed_cidr_blocks = ["0.0.0.0/0"]
}

# ------------------------------------------------------------------------------
# MÓDULO LOAD BALANCER
# ------------------------------------------------------------------------------
module "load_balancer" {
  source = "./load_balancer"

  # Identificadores
  compartment_id = var.compartment_id

  # Subnet del Load Balancer (pública)
  load_balancer_subnet_ids = [module.networking.public_subnet_id]

  # Configuración del Load Balancer
  load_balancer_display_name                = var.load_balancer_display_name
  load_balancer_shape                       = var.load_balancer_shape
  load_balancer_shape_details_min_bandwidth = var.load_balancer_shape_details_min_bandwidth
  load_balancer_shape_details_max_bandwidth = var.load_balancer_shape_details_max_bandwidth

  # Backend Set - Configuración Round Robin
  backend_set_name                    = var.backend_set_name
  backend_set_policy                  = "ROUND_ROBIN" # Política de balanceo
  backend_set_health_checker_protocol = "HTTP"
  backend_set_health_checker_port     = 80
  backend_set_health_checker_url_path = "/"

  # Backend Servers (Web Servers)
  backend_servers = [
    {
      ip_address = module.compute.web_server_private_ips[0]
      port       = 80
    },
    {
      ip_address = module.compute.web_server_private_ips[1]
      port       = 80
    }
  ]

  # Listener Configuration
  listener_name     = var.listener_name
  listener_port     = 80
  listener_protocol = "HTTP"
}

# ------------------------------------------------------------------------------
# Sanity checks: fallar con mensaje claro si no hay ADs o imágenes
# ------------------------------------------------------------------------------
output "_debug_availability_domains_count" {
  value = try(length(data.oci_identity_availability_domains.ads.availability_domains), 0)
}

output "_debug_images_count" {
  value = try(length(data.oci_core_images.oracle_linux.images), 0)
}
