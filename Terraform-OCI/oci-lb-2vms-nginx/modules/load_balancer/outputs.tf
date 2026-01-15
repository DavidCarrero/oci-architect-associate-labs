# ==============================================================================
# LOAD BALANCER MODULE OUTPUTS
# ==============================================================================

# ------------------------------------------------------------------------------
# LOAD BALANCER
# ------------------------------------------------------------------------------

output "load_balancer_id" {
  description = "OCID del load balancer"
  value       = oci_load_balancer_load_balancer.main.id
}

output "load_balancer_ip_addresses" {
  description = "Direcciones IP del load balancer"
  value       = oci_load_balancer_load_balancer.main.ip_address_details[*].ip_address
}

output "load_balancer_state" {
  description = "Estado del load balancer"
  value       = oci_load_balancer_load_balancer.main.state
}

# ------------------------------------------------------------------------------
# BACKEND SET
# ------------------------------------------------------------------------------

output "backend_set_name" {
  description = "Nombre del backend set"
  value       = oci_load_balancer_backend_set.main.name
}

output "backend_set_policy" {
  description = "Política de balanceo del backend set"
  value       = oci_load_balancer_backend_set.main.policy
}

# ------------------------------------------------------------------------------
# LISTENER
# ------------------------------------------------------------------------------

output "listener_name" {
  description = "Nombre del listener HTTP"
  value       = oci_load_balancer_listener.http.name
}

output "listener_port" {
  description = "Puerto del listener"
  value       = oci_load_balancer_listener.http.port
}
