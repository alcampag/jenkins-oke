data "oci_identity_region_subscriptions" "region_subscriptions_data" {
    tenancy_id = var.tenancy_ocid
}

data "oci_containerengine_cluster_kube_config" "cluster_kube_config" {
    cluster_id = local.kube_cluster_id
}

data "oci_artifacts_container_configuration" "container_configuration" {
    compartment_id = var.compartment_id
}

data "oci_identity_user" "current_user" {
    user_id = var.current_user_ocid
}
