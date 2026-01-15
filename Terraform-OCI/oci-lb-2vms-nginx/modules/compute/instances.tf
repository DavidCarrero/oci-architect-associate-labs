# ==============================================================================
# WEB SERVER INSTANCES (Flexible Shape - Preemptible)
# ==============================================================================
# Crea 2 instancias web servers en la subnet privada
# - Shape: VM.Standard.E5.Flex (Preemptible - bajo costo)
# - 1 OCPU, 6 GB RAM
# - Configuración posterior con scripts bash en `compute/scripts/`
#
# NOTA: La configuración de software (Nginx, página web, etc.) se realiza
# mediante los scripts bash ubicados en `compute/scripts/` inyectados como
# `user_data` al crear las instancias.

resource "oci_core_instance" "web_servers" {
  count = var.instance_count

  #Required
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = var.instance_shape

  # Configuración de recursos para Flexible Shape
  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_in_gbs
  }

  # Configuración Preemptible para reducir costos
  preemptible_instance_config {
    preemption_action {
      type = "TERMINATE"
      preserve_boot_volume = false
    }
  }

  display_name = "web-server-${count.index + 1}"

  # ------------------------------------------------------------------------------
  # Source details (imagen del SO)
  # ------------------------------------------------------------------------------
  source_details {
    source_type = "image"
    source_id   = var.instance_image_id
  }

  # ------------------------------------------------------------------------------
  # Network details (subnet privada)
  # ------------------------------------------------------------------------------
  create_vnic_details {
    subnet_id        = var.private_subnet_id
    display_name     = "vnic-web-server-${count.index + 1}"
    assign_public_ip = false # NO asignar IP pública (subnet privada)
    hostname_label   = "webserver${count.index + 1}"
  }

  # ------------------------------------------------------------------------------
  # SSH Keys para acceso
  # ------------------------------------------------------------------------------
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    
    # User data: script de inicialización que despliega servidor web
    user_data = base64encode(templatefile("${path.module}/scripts/web_server_init.sh", {
      server_number = count.index + 1
    }))
  }

  # ------------------------------------------------------------------------------
  # Oracle Cloud Agent - Habilitar plugin de Bastion
  # ------------------------------------------------------------------------------
  agent_config {
    is_management_disabled = false
    is_monitoring_disabled = false
    
    plugins_config {
      name          = "Bastion"
      desired_state = "ENABLED"
    }
  }

  freeform_tags = {
    "Role"        = "WebServer"
    "Environment" = "Production"
    "ManagedBy"   = "Terraform"
  }
}

# ==============================================================================
# NOTA: Bastion tradicional removido
# ==============================================================================
# Se reemplazó la instancia bastion tradicional con OCI Bastion Service
# Ver módulo: modules/bastion/
# Ventajas:
# - Sin instancia corriendo 24/7 (más económico)
# - Acceso bajo demanda con sesiones temporales
# - Más seguro (administrado por Oracle)
# ==============================================================================
