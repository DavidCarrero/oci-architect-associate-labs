# ==============================================================================
# SUBNETS
# ==============================================================================

# ------------------------------------------------------------------------------
# SUBNET PÚBLICA - Para Load Balancer y Bastion
# ------------------------------------------------------------------------------
# Esta subnet permite IPs públicas y tiene ruta hacia Internet Gateway

resource "oci_core_subnet" "public" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = var.public_subnet_cidr_block

  #Optional
  display_name               = var.public_subnet_display_name
  dns_label                  = var.public_subnet_dns_label
  prohibit_public_ip_on_vnic = false # Permite IPs públicas
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]

  freeform_tags = {
    "Type" = "Public"
  }
}

# ------------------------------------------------------------------------------
# SUBNET PRIVADA - Para Web Servers
# ------------------------------------------------------------------------------
# Esta subnet NO permite IPs públicas directas, solo IPs privadas

resource "oci_core_subnet" "private" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = var.private_subnet_cidr_block

  #Optional
  display_name               = var.private_subnet_display_name
  dns_label                  = var.private_subnet_dns_label
  prohibit_public_ip_on_vnic = true # NO permite IPs públicas
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]

  freeform_tags = {
    "Type" = "Private"
  }
}

# ==============================================================================
# ROUTE TABLES
# ==============================================================================

# ------------------------------------------------------------------------------
# ROUTE TABLE PÚBLICA
# ------------------------------------------------------------------------------
# Enruta todo el tráfico 0.0.0.0/0 hacia el Internet Gateway

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "rt-public"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
    description       = "Route to Internet Gateway"
  }
}

# ------------------------------------------------------------------------------
# ROUTE TABLE PRIVADA
# ------------------------------------------------------------------------------
# Enruta tráfico únicamente al Service Gateway
# Service Gateway provee acceso a servicios OCI y salida a internet
# (necesario para plugin de Bastion y descarga de paquetes)

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "rt-private"

  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.main.id
    description       = "Route to Service Gateway for OCI Services"
  }
}

