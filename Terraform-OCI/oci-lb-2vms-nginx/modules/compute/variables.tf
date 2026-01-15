# ==============================================================================
# COMPUTE MODULE VARIABLES
# ==============================================================================

# ------------------------------------------------------------------------------
# COMPARTMENT & AVAILABILITY
# ------------------------------------------------------------------------------

variable "compartment_id" {
  description = "OCID del compartment donde se crearán las instancias"
  type        = string
}

variable "availability_domain" {
  description = "Availability Domain donde se crearán las instancias"
  type        = string
}

# ------------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------------

variable "private_subnet_id" {
  description = "OCID de la subnet privada para los web servers"
  type        = string
}

variable "public_subnet_id" {
  description = "OCID de la subnet pública para el bastion host"
  type        = string
}

# ------------------------------------------------------------------------------
# WEB SERVER INSTANCES
# ------------------------------------------------------------------------------

variable "instance_shape" {
  description = "Shape de las instancias de computación. Flexible: VM.Standard.E5.Flex"
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "instance_ocpus" {
  description = "Número de OCPUs para las instancias web (Flexible shape)"
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Memoria en GB para las instancias web (Flexible shape)"
  type        = number
  default     = 6
}

variable "instance_image_id" {
  description = "OCID de la imagen para las instancias web"
  type        = string
}

variable "instance_count" {
  description = "Número de instancias web a crear"
  type        = number
  default     = 2
}

# ------------------------------------------------------------------------------
# NOTA: Bastion variables removidas
# ------------------------------------------------------------------------------
# Se eliminaron las variables del bastion tradicional ya que ahora se usa
# OCI Bastion Service (módulo bastion/)
# ==============================================================================

# ------------------------------------------------------------------------------
# SSH ACCESS
# ------------------------------------------------------------------------------

variable "ssh_public_key" {
  description = "SSH public key para acceder a las instancias"
  type        = string
}
