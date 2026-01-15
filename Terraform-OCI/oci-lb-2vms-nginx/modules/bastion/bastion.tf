# ==============================================================================
# OCI BASTION SERVICE
# ==============================================================================
# Servicio Bastion administrado de OCI para acceso seguro a instancias privadas
# - No requiere instancia corriendo 24/7
# - Más seguro y económico que bastion tradicional
# - Acceso bajo demanda con sesiones temporales
# ==============================================================================

resource "oci_bastion_bastion" "main" {
  # Required
  bastion_type     = "STANDARD"
  compartment_id   = var.compartment_id
  target_subnet_id = var.private_subnet_id

  # Optional
  name = "bastion-webservers"
  client_cidr_block_allow_list = var.allowed_cidr_blocks
  max_session_ttl_in_seconds   = 10800 # 3 horas

  freeform_tags = {
    "Environment" = "Production"
    "ManagedBy"   = "Terraform"
    "Purpose"     = "SSH Access to Private Web Servers"
  }
}

# ==============================================================================
# DELAY PARA ESPERAR A QUE LOS PLUGINS ESTÉN ACTIVOS
# ==============================================================================
# El plugin Bastion en las INSTANCIAS tarda 10-15 minutos en estar RUNNING 
# después de crear la instancia. Este delay asegura que el plugin esté listo 
# antes de crear las sesiones Bastion.
# ==============================================================================

resource "time_sleep" "wait_for_bastion_plugin" {
  # Depender del bastion service Y de las instancias (via variable)
  depends_on = [
    oci_bastion_bastion.main
  ]
  
  # Triggear cuando cambien las instancias
  triggers = {
    instance_ids = join(",", var.web_server_ids)
  }
  
  create_duration = "15m"  # Esperar 15 minutos para estar seguros
}

# ==============================================================================
# BASTION SSH SESSIONS - AUTO-CREATED
# ==============================================================================
# Crea automáticamente sesiones SSH para ambos web servers
# NOTA: Espera 10 minutos después de crear las instancias para que el plugin
# Bastion esté en estado RUNNING
# ==============================================================================

# Sesión SSH para Web Server 1
resource "oci_bastion_session" "web_server_1" {
  depends_on = [
    oci_bastion_bastion.main,
    time_sleep.wait_for_bastion_plugin
  ]

  # Required
  bastion_id = oci_bastion_bastion.main.id
  
  key_details {
    public_key_content = var.ssh_public_key
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = var.web_server_ids[0]
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = var.web_server_private_ips[0]
  }

  # Optional
  display_name           = "session-web-server-1"
  key_type               = "PUB"
  session_ttl_in_seconds = 10800 # 3 horas

  lifecycle {
    ignore_changes = [
      # Ignorar cambios en TTL para evitar recreación de sesiones
      session_ttl_in_seconds,
    ]
  }
}

# Sesión SSH para Web Server 2
resource "oci_bastion_session" "web_server_2" {
  depends_on = [
    oci_bastion_bastion.main,
    time_sleep.wait_for_bastion_plugin
  ]

  # Required
  bastion_id = oci_bastion_bastion.main.id
  
  key_details {
    public_key_content = var.ssh_public_key
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = var.web_server_ids[1]
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = 22
    target_resource_private_ip_address         = var.web_server_private_ips[1]
  }

  # Optional
  display_name           = "session-web-server-2"
  key_type               = "PUB"
  session_ttl_in_seconds = 10800 # 3 horas

  lifecycle {
    ignore_changes = [
      # Ignorar cambios en TTL para evitar recreación de sesiones
      session_ttl_in_seconds,
    ]
  }
}
