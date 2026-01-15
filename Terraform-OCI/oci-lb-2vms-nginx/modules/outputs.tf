# ==============================================================================
# OUTPUTS - Información de conexión SSH y acceso
# ==============================================================================

# ------------------------------------------------------------------------------
# VCN OUTPUTS
# ------------------------------------------------------------------------------

output "vcn_id" {
  description = "OCID de la VCN creada"
  value       = module.networking.vcn_id
}

output "vcn_cidr_block" {
  description = "CIDR block de la VCN"
  value       = var.vcn_cidr_block
}

# ------------------------------------------------------------------------------
# SUBNET OUTPUTS
# ------------------------------------------------------------------------------

output "public_subnet_id" {
  description = "OCID de la subnet pública"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "OCID de la subnet privada"
  value       = module.networking.private_subnet_id
}

# ------------------------------------------------------------------------------
# LOAD BALANCER OUTPUTS
# ------------------------------------------------------------------------------

output "load_balancer_id" {
  description = "OCID del Load Balancer"
  value       = module.load_balancer.load_balancer_id
}

output "load_balancer_public_ip" {
  description = "IP pública del Load Balancer para acceder a la aplicación web"
  value       = module.load_balancer.load_balancer_ip_addresses
}

output "load_balancer_url" {
  description = "URL del Load Balancer"
  value       = "http://${module.load_balancer.load_balancer_ip_addresses[0]}"
}

# ------------------------------------------------------------------------------
# WEB SERVERS OUTPUTS
# ------------------------------------------------------------------------------

output "web_server_1_private_ip" {
  description = "IP privada del Web Server 1"
  value       = module.compute.web_server_private_ips[0]
}

output "web_server_2_private_ip" {
  description = "IP privada del Web Server 2"
  value       = module.compute.web_server_private_ips[1]
}

output "web_server_ids" {
  description = "OCIDs de los Web Servers"
  value       = module.compute.web_server_ids
}

output "web_server_state" {
  description = "Estado de las instancias Web Servers"
  value       = module.compute.web_server_state
}

output "web_server_time_created" {
  description = "Tiempo de creación de las instancias"
  value       = module.compute.web_server_time_created
}

output "web_server_agent_bastion_status" {
  description = "Estado del plugin Bastion en las instancias"
  value       = module.compute.web_server_agent_bastion_status
}

output "web_server_init_validation" {
  description = "Información para validar la instalación de nginx"
  value       = module.compute.web_server_init_validation
}

# ------------------------------------------------------------------------------
# BASTION SERVICE OUTPUTS
# ------------------------------------------------------------------------------

output "bastion_service_id" {
  description = "OCID del OCI Bastion Service"
  value       = module.bastion.bastion_id
}

output "bastion_service_name" {
  description = "Nombre del OCI Bastion Service"
  value       = module.bastion.bastion_name
}

output "bastion_connection_instructions" {
  description = "Instrucciones para conectarse vía Bastion Service"
  value       = module.bastion.bastion_instructions
}

# ------------------------------------------------------------------------------
# BASTION SESSIONS - SSH COMMANDS
# ------------------------------------------------------------------------------

output "web_server_1_session_id" {
  description = "Session ID para Web Server 1"
  value       = module.bastion.web_server_1_session_id
}

output "web_server_2_session_id" {
  description = "Session ID para Web Server 2"
  value       = module.bastion.web_server_2_session_id
}

output "web_server_1_ssh_command" {
  description = "Comando SSH para conectarse al Web Server 1"
  value       = <<-EOT
    ssh -i C:\Users\practicante_dtic2\.ssh\id_ed25519_utb -o ProxyCommand="ssh -i C:\Users\practicante_dtic2\.ssh\id_ed25519_utb -W %h:%p -p 22 ${module.bastion.web_server_1_session_id}@host.bastion.${data.oci_identity_region_subscriptions.current.region_subscriptions[0].region_name}.oci.oraclecloud.com" opc@${module.compute.web_server_private_ips[0]}
  EOT
}

output "web_server_2_ssh_command" {
  description = "Comando SSH para conectarse al Web Server 2"
  value       = <<-EOT
    ssh -i C:\Users\practicante_dtic2\.ssh\id_ed25519_utb -o ProxyCommand="ssh -i C:\Users\practicante_dtic2\.ssh\id_ed25519_utb -W %h:%p -p 22 ${module.bastion.web_server_2_session_id}@host.bastion.${data.oci_identity_region_subscriptions.current.region_subscriptions[0].region_name}.oci.oraclecloud.com" opc@${module.compute.web_server_private_ips[1]}
  EOT
}

# ------------------------------------------------------------------------------
# INSTRUCCIONES DE ACCESO
# ------------------------------------------------------------------------------

output "access_instructions" {
  description = "Instrucciones para acceder a las instancias y aplicación"
  value       = <<-EOT
    
    ═══════════════════════════════════════════════════════════════
    ✅ INFRAESTRUCTURA DESPLEGADA - LISTO PARA USAR
    ═══════════════════════════════════════════════════════════════
    
    🌐 ACCEDER A LA APLICACIÓN WEB:
       ${module.load_balancer.load_balancer_ip_addresses[0]}
       
       Refresca varias veces para ver Round Robin entre Server #1 y #2
    
    🔐 CONECTAR VIA SSH (SESIONES YA CREADAS):
    
       📌 Web Server 1:
          terraform output -raw web_server_1_ssh_command | sh
       
       📌 Web Server 2:
          terraform output -raw web_server_2_ssh_command | sh
    
    ⚙️ VERIFICAR NGINX EN SERVIDORES:
       sudo systemctl status nginx
       curl http://localhost
    
    🔥 CONFIGURAR FIREWALL (si backends en CRITICAL):
       sudo firewall-cmd --permanent --add-service=http
       sudo firewall-cmd --reload
    
    ═══════════════════════════════════════════════════════════════
    
  EOT
}
