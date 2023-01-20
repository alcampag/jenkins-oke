//noinspection HILUnresolvedReference
locals {
  kube_cluster_id = var.create_oke_cluster ? module.oke.0.cluster_id : var.oke_cluster_id
  node_pools = {
    np1 = {shape="VM.Standard.E4.Flex",ocpus=2,memory=16,node_pool_size=2}
  }

  registry_username = "${data.oci_artifacts_container_configuration.container_configuration.namespace}/${data.oci_identity_user.current_user.name}"
  jenkins_plugins_string = join(" ", var.jenkins_plugins)

  kube_host                   = yamldecode(data.oci_containerengine_cluster_kube_config.cluster_kube_config.content).clusters.0.cluster.server
  kube_cluster_ca_certificate = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.cluster_kube_config.content).clusters.0.cluster.certificate-authority-data)
}
