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
