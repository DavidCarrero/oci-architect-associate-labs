# ==============================================================================
# DATA SOURCES - COMPUTE MODULE
# ==============================================================================

# ------------------------------------------------------------------------------
# Obtener Availability Domains
# ------------------------------------------------------------------------------
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# ------------------------------------------------------------------------------
# Obtener imágenes de Oracle Linux 8 disponibles
# ------------------------------------------------------------------------------
# Se filtran por sistema operativo, versión y shape compatible

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ------------------------------------------------------------------------------
# Obtener shapes disponibles (Always Free tier)
# ------------------------------------------------------------------------------
# Lista de shapes disponibles para verificar la disponibilidad

data "oci_core_shapes" "available_shapes" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
}
