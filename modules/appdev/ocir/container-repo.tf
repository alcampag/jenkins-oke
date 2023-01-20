resource "oci_artifacts_container_repository" "container_repos" {
    count = length(var.container_repo_configs)
    compartment_id = var.compartment_id
    display_name = var.container_repo_configs[count.index].display_name

    is_public = var.container_repo_configs[count.index].is_public
    
}