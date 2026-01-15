# ==============================================================================
# INTERNET GATEWAY
# ==============================================================================
# Permite comunicación entre la VCN e Internet
# Es usado por ambas subnets para tráfico saliente
# La subnet pública también lo usa para tráfico entrante

resource "oci_core_internet_gateway" "main" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id

  #Optional
  display_name = var.internet_gateway_display_name
  enabled      = true

  freeform_tags = {
    "ManagedBy" = "Terraform"
  }
}

# ==============================================================================
# SERVICE GATEWAY
# ==============================================================================
# Permite que las instancias en subnet privada accedan a servicios OCI
# (Object Storage, Oracle Services Network) sin salir a Internet público
# Necesario para que funcione el plugin de Bastion

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "main" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }

  #Optional
  display_name = var.service_gateway_display_name

  freeform_tags = {
    "ManagedBy" = "Terraform"
  }
}

