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
