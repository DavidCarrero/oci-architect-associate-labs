# ==============================================================================
# NETWORKING MODULE VARIABLES
# ==============================================================================

# ------------------------------------------------------------------------------
# COMPARTMENT
# ------------------------------------------------------------------------------

variable "compartment_id" {
  description = "OCID del compartment donde se crearán los recursos de red"
  type        = string
}

# ------------------------------------------------------------------------------
# VCN
# ------------------------------------------------------------------------------

variable "vcn_cidr_block" {
  description = "CIDR block para la VCN"
  type        = string
}

variable "vcn_display_name" {
  description = "Nombre para mostrar de la VCN"
  type        = string
}

variable "vcn_dns_label" {
  description = "DNS label para la VCN"
  type        = string
}

# ------------------------------------------------------------------------------
# SUBNET PÚBLICA
# ------------------------------------------------------------------------------

variable "public_subnet_cidr_block" {
  description = "CIDR block para la subnet pública (Load Balancer + Bastion)"
  type        = string
}

variable "public_subnet_display_name" {
  description = "Nombre para mostrar de la subnet pública"
  type        = string
}

variable "public_subnet_dns_label" {
  description = "DNS label para la subnet pública"
  type        = string
}

# ------------------------------------------------------------------------------
# SUBNET PRIVADA
# ------------------------------------------------------------------------------

variable "private_subnet_cidr_block" {
  description = "CIDR block para la subnet privada (Web Servers)"
  type        = string
}

variable "private_subnet_display_name" {
  description = "Nombre para mostrar de la subnet privada"
  type        = string
}

variable "private_subnet_dns_label" {
  description = "DNS label para la subnet privada"
  type        = string
}

# ------------------------------------------------------------------------------
# INTERNET GATEWAY
# ------------------------------------------------------------------------------

variable "internet_gateway_display_name" {
  description = "Nombre para mostrar del Internet Gateway"
  type        = string
}

variable "service_gateway_display_name" {
  description = "Nombre para mostrar del Service Gateway"
  type        = string
  default     = "sgw-main"
}
