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

output "web_server_instances" {
  description = "Objetos completos de las instancias web servers (para depends_on)"
  value       = oci_core_instance.web_servers
}

output "web_server_state" {
  description = "Estado de las instancias web servers"
  value       = oci_core_instance.web_servers[*].state
}

output "web_server_time_created" {
  description = "Tiempo de creación de las instancias"
  value       = oci_core_instance.web_servers[*].time_created
}

output "web_server_agent_bastion_status" {
  description = "Estado del plugin Bastion en las instancias (debe ser RUNNING para crear sesiones)"
  value = [
    for instance in oci_core_instance.web_servers : {
      hostname = instance.display_name
      id       = instance.id
      bastion_plugin = "Check in OCI Console: Instance Details -> Oracle Cloud Agent -> Bastion Plugin Status"
    }
  ]
}

# ------------------------------------------------------------------------------
# INFORMACIÓN PARA VALIDAR INSTALACIÓN DE NGINX
# ------------------------------------------------------------------------------

output "web_server_init_validation" {
  description = "Comandos para validar que nginx se instaló correctamente en las instancias"
  value = {
    note = "Para validar la instalación de nginx, conéctate a las instancias vía Bastion y ejecuta:"
    commands = [
      "sudo systemctl status nginx",
      "sudo cat /var/log/user-data.log",
      "curl -I http://localhost",
      "sudo netstat -tlnp | grep :80"
    ]
    user_data_script = "El script de inicialización está en: modules/compute/scripts/web_server_init.sh"
    cloud_init_logs = "/var/log/cloud-init-output.log y /var/log/user-data.log"
  }
}

# ------------------------------------------------------------------------------
# BASTION - Removido (usando OCI Bastion Service en su lugar)
# ------------------------------------------------------------------------------
# Ver módulo: modules/bastion/ para acceso vía Bastion Service
