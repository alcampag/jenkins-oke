

module "oke" {
  source  = "oracle-terraform-modules/oke/oci"
  version = "4.4.1"
  tenancy_id = var.tenancy_ocid
  home_region = element([for reg in data.oci_identity_region_subscriptions.region_subscriptions_data.region_subscriptions : reg if reg.is_home_region ],0).region_name
  region = var.region
  compartment_id = local.oke_compartment_id
  create_vcn = true
  vcn_cidrs = var.oke_vcn_cidrs
  vcn_name = var.oke_vcn_name
  create_bastion_host = false
  create_operator = false
  cluster_name = var.oke_cluster_name
  cni_type = "flannel"
  control_plane_type = "public"
  control_plane_allowed_cidrs = ["0.0.0.0/0"]
  kubernetes_version = var.kubernetes_version
  create_policies = false
  load_balancers = "public"
  public_lb_allowed_cidrs = ["0.0.0.0/0"]
  public_lb_allowed_ports = [443,80]
  create_fss = false
  node_pool_name_prefix = ""
  node_pool_os_version = "8.6"
  node_pools = var.create_node_pool ? local.node_pools : null
  freeform_tags = {
    oke = {
      cluster = {}
      persistent_volume = {}
      service_lb = {}
    }
    vcn = {}
    bastion = {}
    operator = {}
  }
  providers = {
    oci.home = oci.home
  }
  count = var.create_oke_cluster ? 1 : 0
}

# docker and Kubectl (1.23) ARE in the Resource Manager

module "ocir" {
  source = "./modules/appdev/ocir"
  container_repo_configs = [{
    display_name = var.custom_image_name
    is_public    = false
  }]
  compartment_id = local.ocir_compartment_id
  region         = var.region
}


resource "local_file" "jenkins_dockerfile" {
  filename = "./Dockerfile"
  content  = templatefile("./templates/Dockerfile.tpl", { plugins = local.jenkins_plugins_string })

  depends_on = [
    module.ocir,
    module.oke
  ]
}

resource "null_resource" "build_custom_jenkins_image" {

  provisioner "local-exec" {
    command     = "chmod +x ./scripts/create-jenkins-image.sh && ./scripts/create-jenkins-image.sh"
    environment = {
      BASE_PATH         = module.ocir.base_path
      REPO_NAME         = module.ocir.container_registries.0.display_name
      DOCKER_TAG        = var.custom_image_tag
      REGISTRY_HOSTNAME = module.ocir.registry_hostname
      DOCKER_USERNAME   = local.registry_username
      DOCKER_PASSWORD   = var.auth_token
    }
    working_dir = path.root
  }

  triggers = {
    dockerfile_sha = sha256(local_file.jenkins_dockerfile.content)
  }

  depends_on = [
    module.ocir,
    module.oke,
    local_file.jenkins_dockerfile
  ]
}

module "jenkins" {
  source = "./modules/jenkins"
  image = "${module.ocir.base_path}/${module.ocir.container_registries.0.display_name}"
  tag = var.custom_image_tag
  registry_username = local.registry_username
  registry_password = var.auth_token
  registry_email = "arch@oracle.com"
  registry_server = module.ocir.registry_hostname
  registry_id = module.ocir.container_registries.0.id
  registry_compartment_id = var.ocir_compartment_id
  jenkins_admin_password = var.jenkins_admin_password
  agent_namespace = var.agent_namespace
  create_agent_namespace = var.create_agent_namespace
  jenkins_admin_username = var.jenkins_admin_username
  jenkins_controller_namespace = var.jenkins_controller_namespace
  jenkins_service_name = var.jenkins_service_name
  jenkins_service_port = var.jenkins_service_port
  max_concurrent_agents = var.max_concurrent_agents
  depends_on = [
    null_resource.build_custom_jenkins_image,
    module.oke,
    module.ocir
  ]
}
