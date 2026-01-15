# ==============================================================================
# BASTION MODULE - VARIABLES
# ==============================================================================

variable "compartment_id" {
  description = "OCID del compartment"
  type        = string
}

variable "private_subnet_id" {
  description = "OCID de la subnet privada donde están las instancias web"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "Lista de bloques CIDR permitidos para conectarse al bastion"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Cambiar a tu IP pública para mayor seguridad
}

variable "ssh_public_key" {
  description = "SSH public key para las sesiones Bastion"
  type        = string
}

variable "web_server_ids" {
  description = "Lista de OCIDs de los web servers"
  type        = list(string)
}

variable "web_server_private_ips" {
  description = "Lista de IPs privadas de los web servers"
  type        = list(string)
}

variable "web_server_instances" {
  description = "Lista de objetos completos de las instancias web servers (para depends_on)"
  type        = any
  default     = []
}
