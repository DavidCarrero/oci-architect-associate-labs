# ==============================================================================
# COMPUTE MODULE OUTPUTS
# ==============================================================================

# ------------------------------------------------------------------------------
# WEB SERVERS
# ------------------------------------------------------------------------------

output "web_server_ids" {
  description = "OCIDs de los web servers"
  value       = oci_core_instance.web_servers[*].id
}

output "web_server_private_ips" {
  description = "IPs privadas de los web servers"
  value       = oci_core_instance.web_servers[*].private_ip
}

output "web_server_hostnames" {
  description = "Hostnames de los web servers"
  value       = oci_core_instance.web_servers[*].display_name
}

# ------------------------------------------------------------------------------
# BASTION - Removido (usando OCI Bastion Service en su lugar)
# ------------------------------------------------------------------------------
# Ver módulo: modules/bastion/ para acceso vía Bastion Service
