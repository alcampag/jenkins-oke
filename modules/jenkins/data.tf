data "oci_artifacts_container_images" "ocir_images" {
    compartment_id = var.registry_compartment_id
    
    repository_id = var.registry_id
    version = var.tag
}

/*
data "kubernetes_storage_class" "storage_class" {
    metadata {
        name = "bv-encrypted-storage-class"
    }
}*/
