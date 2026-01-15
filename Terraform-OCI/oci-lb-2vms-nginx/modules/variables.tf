# ==============================================================================
# COMPARTMENT VARIABLES
# ==============================================================================

variable "compartment_id" {
  description = "OCID del compartment donde se crearán los recursos"
  type        = string
}

# ==============================================================================
# NETWORKING VARIABLES
# ==============================================================================

variable "vcn_cidr_block" {
  description = "CIDR block para la VCN"
  type        = string
  default     = "172.17.0.0/16"
}

variable "vcn_display_name" {
  description = "Nombre de la VCN"
  type        = string
  default     = "vcn-lb-webservers"
}

variable "vcn_dns_label" {
  description = "DNS label para la VCN"
  type        = string
  default     = "vcnlb"
}

variable "public_subnet_cidr_block" {
  description = "CIDR block para la subnet pública (Load Balancer + Bastion)"
  type        = string
  default     = "172.17.1.0/24"
}

variable "public_subnet_display_name" {
  description = "Nombre de la subnet pública"
  type        = string
  default     = "subnet-public"
}

variable "public_subnet_dns_label" {
  description = "DNS label para la subnet pública"
  type        = string
  default     = "public"
}

variable "private_subnet_cidr_block" {
  description = "CIDR block para la subnet privada (Web Servers)"
  type        = string
  default     = "172.17.2.0/24"
}

variable "private_subnet_display_name" {
  description = "Nombre de la subnet privada"
  type        = string
  default     = "subnet-private"
}

variable "private_subnet_dns_label" {
  description = "DNS label para la subnet privada"
  type        = string
  default     = "private"
}

variable "internet_gateway_display_name" {
  description = "Nombre del Internet Gateway"
  type        = string
  default     = "igw-main"
}

# ==============================================================================
# COMPUTE VARIABLES (Web Servers + Bastion)
# ==============================================================================

variable "instance_shape" {
  description = "Shape para las instancias web (Always Free tier)"
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "bastion_shape" {
  description = "Shape para la instancia bastion (Always Free tier)"
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "instance_ocpus" {
  description = "Número de OCPUs para instancias web (flexible shapes)"
  type        = number
  default     = 1
}

variable "instance_memory_in_gbs" {
  description = "Memoria en GB para instancias web (flexible shapes)"
  type        = number
  default     = 6
}

variable "bastion_ocpus" {
  description = "Número de OCPUs para bastion (flexible shapes)"
  type        = number
  default     = 1
}

variable "bastion_memory_in_gbs" {
  description = "Memoria en GB para bastion (flexible shapes)"
  type        = number
  default     = 6
}

variable "ssh_public_key" {
  description = "SSH public key para acceder a las instancias"
  type        = string
}

# ==============================================================================
# LOAD BALANCER VARIABLES
# ==============================================================================

variable "load_balancer_display_name" {
  description = "Nombre del Load Balancer"
  type        = string
  default     = "lb-web-servers"
}

variable "load_balancer_shape" {
  description = "Shape del Load Balancer (flexible para Always Free)"
  type        = string
  default     = "flexible"
}

variable "load_balancer_shape_details_min_bandwidth" {
  description = "Ancho de banda mínimo en Mbps (10 para Always Free)"
  type        = number
  default     = 10
}

variable "load_balancer_shape_details_max_bandwidth" {
  description = "Ancho de banda máximo en Mbps (10 para Always Free)"
  type        = number
  default     = 10
}

variable "backend_set_name" {
  description = "Nombre del Backend Set"
  type        = string
  default     = "backend-web-servers"
}

variable "listener_name" {
  description = "Nombre del Listener"
  type        = string
  default     = "listener-http"
}
