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

output "bastion_instructions" {
  description = "Instrucciones para crear sesiones SSH"
  value       = <<-EOT
  
  ═══════════════════════════════════════════════════════════════
  INSTRUCCIONES PARA CONECTARSE VIA BASTION SERVICE
  ═══════════════════════════════════════════════════════════════
  
  1. Crear sesión SSH desde OCI Console:
     - Ir a: Identity & Security > Bastion > ${oci_bastion_bastion.main.name}
     - Click en "Create session"
     - Session type: "Managed SSH session"
     - Seleccionar instancia target (web-server-1 o web-server-2)
     - Username: opc
     - Upload SSH public key: ~/.ssh/id_rsa.pub
     - Session TTL: 3 hours
  
  2. Copiar comando SSH generado y ejecutar en tu terminal local
  
  3. Alternativamente, usar OCI CLI:
     
     oci bastion session create-managed-ssh \
       --bastion-id ${oci_bastion_bastion.main.id} \
       --target-resource-id <INSTANCE_OCID> \
       --target-os-username opc \
       --ssh-public-key-file ~/.ssh/id_rsa.pub \
       --session-ttl-in-seconds 10800
  
  ═══════════════════════════════════════════════════════════════
  
  EOT
}
