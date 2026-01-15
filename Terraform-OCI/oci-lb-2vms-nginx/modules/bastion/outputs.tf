# ==============================================================================
# BASTION MODULE - OUTPUTS
# ==============================================================================

output "bastion_id" {
  description = "OCID del servicio Bastion"
  value       = oci_bastion_bastion.main.id
}

output "bastion_name" {
  description = "Nombre del servicio Bastion"
  value       = oci_bastion_bastion.main.name
}

output "bastion_state" {
  description = "Estado del servicio Bastion"
  value       = oci_bastion_bastion.main.state
}

output "bastion_private_endpoint_ip" {
  description = "IP privada del endpoint del Bastion"
  value       = oci_bastion_bastion.main.private_endpoint_ip_address
}

# ==============================================================================
# BASTION SESSIONS OUTPUTS
# ==============================================================================

output "web_server_1_session_id" {
  description = "Session ID para conectarse al Web Server 1"
  value       = oci_bastion_session.web_server_1.id
}

output "web_server_2_session_id" {
  description = "Session ID para conectarse al Web Server 2"
  value       = oci_bastion_session.web_server_2.id
}

output "web_server_1_ssh_metadata" {
  description = "Metadata de SSH para Web Server 1"
  value       = oci_bastion_session.web_server_1.ssh_metadata
  sensitive   = true
}

output "web_server_2_ssh_metadata" {
  description = "Metadata de SSH para Web Server 2"
  value       = oci_bastion_session.web_server_2.ssh_metadata
  sensitive   = true
}

output "bastion_instructions" {
  description = "Instrucciones para conectarse vía Bastion Service"
  value       = <<-EOT
  
  ═══════════════════════════════════════════════════════════════
  INSTRUCCIONES PARA CONECTARSE VIA BASTION SERVICE
  ═══════════════════════════════════════════════════════════════
  
  SESIONES YA CREADAS AUTOMÁTICAMENTE:
  - Web Server 1: ${oci_bastion_session.web_server_1.display_name}
  - Web Server 2: ${oci_bastion_session.web_server_2.display_name}
  
  ═══════════════════════════════════════════════════════════════
  COMANDOS SSH LISTOS PARA USAR
  ═══════════════════════════════════════════════════════════════
  
  Ver outputs: web_server_1_ssh_command y web_server_2_ssh_command
  
  ═══════════════════════════════════════════════════════════════
  EOT
}
