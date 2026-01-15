terraform {
  required_version = ">= 1.0.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "7.29.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# Provider configuration for OCI using config file profile
# Uses the DEFAULT profile from ~/.oci/config
provider "oci" {
  config_file_profile = "DEFAULT"
}


