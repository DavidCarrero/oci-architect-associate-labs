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
# INSTRUCCIONES DE ACCESO
# ------------------------------------------------------------------------------

output "access_instructions" {
  description = "Instrucciones para acceder a las instancias y aplicación"
  value       = <<-EOT
    
    ═══════════════════════════════════════════════════════════════
    INSTRUCCIONES DE ACCESO
    ═══════════════════════════════════════════════════════════════
    
    1. ACCEDER A LA APLICACIÓN WEB:
       URL: http://${module.load_balancer.load_balancer_ip_addresses[0]}
       
       El Load Balancer distribuye peticiones entre 2 web servers
       usando política Round Robin.
    
    2. CONECTAR A INSTANCIAS WEB (via Bastion Service):
       - Ir a OCI Console: Identity & Security > Bastion
       - Seleccionar Bastion: ${module.bastion.bastion_name}
       - Click "Create session"
       - Seleccionar instancia target (web-server-1 o web-server-2)
       - Copiar y ejecutar comando SSH generado
    
    3. USAR "RUN COMMAND" EN OCI CONSOLE:
       - Compute > Instances > [web-server-1 o web-server-2]
       - Oracle Cloud Agent > Run Command
       - Pegar comandos para instalar nginx (ver abajo)
    
    ═══════════════════════════════════════════════════════════════
    
  EOT
}
