# ==============================================================================
# VCN (Virtual Cloud Network)
# ==============================================================================
# Crea la VCN principal con el rango CIDR 172.17.0.0/16

resource "oci_core_vcn" "main" {
  #Required
  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr_block

  #Optional
  display_name = var.vcn_display_name
  dns_label    = var.vcn_dns_label

  freeform_tags = {
    "Environment" = "Production"
    "ManagedBy"   = "Terraform"
  }
}
