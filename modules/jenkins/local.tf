locals {
  digest = data.oci_artifacts_container_images.ocir_images.container_image_collection.0.items.0.digest
  agent_namespace = var.create_agent_namespace ? var.agent_namespace : var.jenkins_controller_namespace
}