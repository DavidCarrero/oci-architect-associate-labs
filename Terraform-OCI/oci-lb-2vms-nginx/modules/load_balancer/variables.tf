# ==============================================================================
# LOAD BALANCER MODULE VARIABLES
# ==============================================================================

# ------------------------------------------------------------------------------
# COMPARTMENT
# ------------------------------------------------------------------------------

variable "compartment_id" {
  description = "OCID del compartment donde se creará el load balancer"
  type        = string
}

# ------------------------------------------------------------------------------
# LOAD BALANCER CONFIGURATION
# ------------------------------------------------------------------------------

variable "load_balancer_display_name" {
  description = "Nombre del load balancer"
  type        = string
}

variable "load_balancer_shape" {
  description = "Shape del load balancer (flexible para Always Free)"
  type        = string
}

variable "load_balancer_subnet_ids" {
  description = "Lista de subnet IDs donde se colocará el load balancer (subnet pública)"
  type        = list(string)
}

variable "load_balancer_shape_details_min_bandwidth" {
  description = "Ancho de banda mínimo en Mbps (10 para Always Free)"
  type        = number
}

variable "load_balancer_shape_details_max_bandwidth" {
  description = "Ancho de banda máximo en Mbps (10 para Always Free)"
  type        = number
}

# ------------------------------------------------------------------------------
# BACKEND SET CONFIGURATION
# ------------------------------------------------------------------------------

variable "backend_set_name" {
  description = "Nombre del backend set"
  type        = string
}

variable "backend_set_policy" {
  description = "Política de balanceo (ROUND_ROBIN, LEAST_CONNECTIONS, IP_HASH)"
  type        = string
  default     = "ROUND_ROBIN"
}

variable "backend_set_health_checker_protocol" {
  description = "Protocolo del health checker (HTTP, HTTPS, TCP)"
  type        = string
  default     = "HTTP"
}

variable "backend_set_health_checker_port" {
  description = "Puerto del health checker"
  type        = number
  default     = 80
}

variable "backend_set_health_checker_url_path" {
  description = "URL path para el health checker"
  type        = string
  default     = "/"
}

# ------------------------------------------------------------------------------
# BACKEND SERVERS
# ------------------------------------------------------------------------------

variable "backend_servers" {
  description = "Lista de backend servers con ip_address y port"
  type = list(object({
    ip_address = string
    port       = number
  }))
}

# ------------------------------------------------------------------------------
# LISTENER CONFIGURATION
# ------------------------------------------------------------------------------

variable "listener_name" {
  description = "Nombre del listener"
  type        = string
}

variable "listener_port" {
  description = "Puerto del listener"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocolo del listener (HTTP, HTTPS)"
  type        = string
  default     = "HTTP"
}
