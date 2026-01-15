# ==============================================================================
# LOAD BALANCER
# ==============================================================================
# Load Balancer flexible en subnet pública con bandwidth mínimo para Always Free

resource "oci_load_balancer_load_balancer" "main" {
  #Required
  compartment_id = var.compartment_id
  display_name   = var.load_balancer_display_name
  shape          = var.load_balancer_shape
  subnet_ids     = var.load_balancer_subnet_ids

  #Optional - Shape details para flexible shape
  shape_details {
    maximum_bandwidth_in_mbps = var.load_balancer_shape_details_max_bandwidth
    minimum_bandwidth_in_mbps = var.load_balancer_shape_details_min_bandwidth
  }

  is_private = false # Load Balancer público

  freeform_tags = {
    "ManagedBy"   = "Terraform"
    "Environment" = "Production"
  }
}

# ==============================================================================
# BACKEND SET - Round Robin Policy
# ==============================================================================
# Define el grupo de servidores backend y la política de balanceo

resource "oci_load_balancer_backend_set" "main" {
  #Required
  name             = var.backend_set_name
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  policy           = var.backend_set_policy # ROUND_ROBIN

  #Optional - Health Checker
  health_checker {
    protocol          = var.backend_set_health_checker_protocol
    port              = var.backend_set_health_checker_port
    url_path          = var.backend_set_health_checker_url_path
    interval_ms       = 10000 # 10 segundos
    timeout_in_millis = 3000  # 3 segundos
    retries           = 3
    return_code       = 200
  }
}

# ==============================================================================
# BACKEND SERVERS
# ==============================================================================
# Registra cada web server como backend

resource "oci_load_balancer_backend" "web_servers" {
  count = length(var.backend_servers)

  #Required
  backendset_name  = oci_load_balancer_backend_set.main.name
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  ip_address       = var.backend_servers[count.index].ip_address
  port             = var.backend_servers[count.index].port

  #Optional
  backup  = false
  drain   = false
  offline = false
  weight  = 1 # Peso igual para Round Robin balanceado
}

# ==============================================================================
# LISTENER HTTP
# ==============================================================================
# Listener en puerto 80 que dirige tráfico al backend set

resource "oci_load_balancer_listener" "http" {
  #Required
  load_balancer_id         = oci_load_balancer_load_balancer.main.id
  name                     = var.listener_name
  default_backend_set_name = oci_load_balancer_backend_set.main.name
  port                     = var.listener_port
  protocol                 = var.listener_protocol

  #Optional
  connection_configuration {
    idle_timeout_in_seconds = 60
  }
}
