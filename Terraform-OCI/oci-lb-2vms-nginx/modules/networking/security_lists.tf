# ==============================================================================
# SECURITY LISTS
# ==============================================================================

# ------------------------------------------------------------------------------
# SECURITY LIST PÚBLICA - Load Balancer y Bastion
# ------------------------------------------------------------------------------
# Reglas de seguridad para la subnet pública:
# - Permite HTTP (80) desde cualquier IP para el Load Balancer
# - Permite SSH (22) desde cualquier IP para el Bastion (ajustar en producción)
# - Permite tráfico interno de la VCN

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "sl-public"

  # ====================
  # INGRESS RULES
  # ====================

  # Permitir HTTP (80) desde Internet para el Load Balancer
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "191.93.96.49/32"
    source_type = "CIDR_BLOCK"
    description = "Allow HTTP traffic to Load Balancer"

    tcp_options {
      min = 80
      max = 80
    }
  }

  # Permitir SSH (22) desde Internet para el Bastion
  # IMPORTANTE: En producción, cambiar 0.0.0.0/0 por tu IP específica
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "191.93.96.49/32"
    source_type = "CIDR_BLOCK"
    description = "Allow SSH to Bastion Host"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Permitir todo el tráfico desde la VCN (interno)
  ingress_security_rules {
    protocol    = "all"
    source      = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow all traffic from VCN"
  }

  # Permitir ICMP para diagnóstico (ping)
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "191.93.96.49/32"
    source_type = "CIDR_BLOCK"
    description = "Allow ICMP (ping)"
  }

  # ====================
  # EGRESS RULES
  # ====================

  # Permitir todo el tráfico saliente
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all outbound traffic"
  }
}

# ------------------------------------------------------------------------------
# SECURITY LIST PRIVADA - Web Servers
# ------------------------------------------------------------------------------
# Reglas de seguridad para la subnet privada:
# - Permite HTTP (80) solo desde la subnet pública (Load Balancer)
# - Permite SSH (22) solo desde la subnet pública (Bastion)
# - Permite tráfico interno de la VCN

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "sl-private"

  # ====================
  # INGRESS RULES
  # ====================

  # Permitir HTTP (80) solo desde la subnet pública
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.public_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow HTTP from Load Balancer"

    tcp_options {
      min = 80
      max = 80
    }
  }

  # Permitir SSH (22) solo desde la subnet pública (Bastion)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.public_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow SSH from Bastion"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Permitir todo el tráfico desde la VCN (interno)
  ingress_security_rules {
    protocol    = "all"
    source      = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow all traffic from VCN"
  }

  # Permitir ICMP para diagnóstico (ping)
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    description = "Allow ICMP (ping) from VCN"
  }

  # ====================
  # EGRESS RULES
  # ====================

  # Permitir todo el tráfico saliente
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    description      = "Allow all outbound traffic"
  }
}

