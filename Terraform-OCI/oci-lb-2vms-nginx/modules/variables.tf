variable "tenancy_ocid" {
  description = "OCI tenancy OCID. Leave null if using instance principal or config file."
  type        = string
  default     = null
}

variable "user_ocid" {
  description = "OCI user OCID."
  type        = string
  default     = null
}

variable "fingerprint" {
  description = "API key fingerprint for the OCI user."
  type        = string
  default     = null
}

variable "private_key_path" {
  description = "Path to the private key file for the OCI API key."
  type        = string
  default     = null
}

variable "region" {
  description = "OCI region (e.g. eu-frankfurt-1)."
  type        = string
  default     = null
}

variable "config_file_profile" {
  description = "Optional OCI CLI config file profile name (used if not passing explicit credentials)."
  type        = string
  default     = null
}
