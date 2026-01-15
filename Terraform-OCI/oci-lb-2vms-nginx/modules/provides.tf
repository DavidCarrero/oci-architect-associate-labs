terraform {
	required_version = ">= 1.0.0"

	required_providers {
		oci = {
			source  = "hashicorp/oci"
			version = "7.29.0"
		}
	}
}

# Provider configuration example for OCI (adjust variables or use env/config file)
provider "oci" {
	tenancy_ocid     = var.tenancy_ocid
	user_ocid        = var.user_ocid
	fingerprint      = var.fingerprint
	private_key_path = var.private_key_path
	region           = var.region

	# If you prefer using a shared CLI config file/profile, uncomment:
	# config_file_profile = var.config_file_profile
}


