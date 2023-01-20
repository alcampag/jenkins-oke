locals {
    region_key = lower([for region in data.oci_identity_regions.list_regions.regions : region.key if region.name == var.region ][0])
    namespace = data.oci_artifacts_container_configuration.container_configuration.namespace
    base_registry_path = "${local.region_key}.ocir.io/${local.namespace}"
}