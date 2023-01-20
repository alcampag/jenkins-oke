output "container_registries" {
    value = oci_artifacts_container_repository.container_repos
}

output "base_path" {
  value = local.base_registry_path
}

output "registry_hostname" {
  value = "${local.region_key}.ocir.io"
}