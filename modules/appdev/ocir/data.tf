data "oci_artifacts_container_configuration" "container_configuration" {
    compartment_id = var.compartment_id
}

data "oci_identity_regions" "list_regions" {
}