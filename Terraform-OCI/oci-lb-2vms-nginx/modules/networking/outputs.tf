# ==============================================================================
# NETWORKING MODULE OUTPUTS
# ==============================================================================

# ------------------------------------------------------------------------------
# VCN OUTPUTS
# ------------------------------------------------------------------------------

output "vcn_id" {
  description = "OCID de la VCN creada"
  value       = oci_core_vcn.main.id
}

output "vcn_cidr_block" {
  description = "CIDR block de la VCN"
  value       = oci_core_vcn.main.cidr_block
}

# ------------------------------------------------------------------------------
# SUBNET OUTPUTS
# ------------------------------------------------------------------------------

output "public_subnet_id" {
  description = "OCID de la subnet pública"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID de la subnet privada"
  value       = oci_core_subnet.private.id
}

# ------------------------------------------------------------------------------
# INTERNET GATEWAY OUTPUT
# ------------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "OCID del Internet Gateway"
  value       = oci_core_internet_gateway.main.id
}

output "service_gateway_id" {
  description = "OCID del Service Gateway"
  value       = oci_core_service_gateway.main.id
}

# ------------------------------------------------------------------------------
# SECURITY LIST OUTPUTS
# ------------------------------------------------------------------------------

output "public_security_list_id" {
  description = "OCID de la security list pública"
  value       = oci_core_security_list.public.id
}

output "private_security_list_id" {
  description = "OCID de la security list privada"
  value       = oci_core_security_list.private.id
}
