# ==============================================================================
# DATA SOURCES - LOAD BALANCER MODULE
# ==============================================================================

# ------------------------------------------------------------------------------
# Obtener Load Balancer Shapes disponibles
# ------------------------------------------------------------------------------
# Lista los shapes disponibles para load balancers en el compartment
# Incluye información sobre capacidades y límites de cada shape

data "oci_load_balancer_shapes" "available" {
  compartment_id = var.compartment_id
}

# ------------------------------------------------------------------------------
# Obtener Load Balancer Policies disponibles
# ------------------------------------------------------------------------------
# Lista las políticas de balanceo disponibles:
# - ROUND_ROBIN: distribuye el tráfico equitativamente
# - LEAST_CONNECTIONS: envía al servidor con menos conexiones
# - IP_HASH: asigna cliente a servidor basado en IP

data "oci_load_balancer_policies" "available" {
  compartment_id = var.compartment_id
}

