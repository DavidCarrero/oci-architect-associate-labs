terraform {
  required_version = ">= 1.0.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "7.29.0"
    }
  }
}

# Provider configuration for OCI using config file profile DEFAULT
# Profile DEFAULT uses sa-bogota-1 region
provider "oci" {
  config_file_profile = "DEFAULT"
  region              = "sa-bogota-1"
}


