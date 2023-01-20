variable "tenancy_ocid" {} # (tenancy OCID), already provided on stack and pipeline
variable "compartment_ocid" {} # (compartment OCID), already provided on stack
variable "region" {} # (region), already provided on stack
variable "current_user_ocid" {}

variable "create_oke_cluster" {
  type = bool
  default = true
}

variable "existing_oke_compartment_id" {
  default = null
  description = "To be set only if create_oke_cluster is false"
}

variable "oke_cluster_id" {
  default = null
}

variable "jenkins_controller_namespace" {
  default = "jenkins"
}

variable "jenkins_admin_username" {
  default = "admin"
}

variable "jenkins_admin_password" {
  sensitive = true
}

variable "jenkins_service_name" {
  default = "jenkins-controller"
}

variable "jenkins_service_port" {
  type = number
  default = 80
}

variable "create_agent_namespace" {
  type = bool
  default = true
}

variable "agent_namespace" {
  default = "jenkins-agents"
}

variable "max_concurrent_agents" {
  type = number
  default = 15
}

variable "oke_compartment_id" {
  default = null
  description = "To be set only if create_oke_cluster is true"
}

variable "oke_cluster_name" {
  default = "oke-devops"
}
variable "kubernetes_version" {
  default = "v1.25.4"
}
variable "oke_vcn_name" {
  default = "oke-vcn"
}
variable "oke_vcn_cidrs" {
  type = list(string)
  default = ["10.0.0.0/16"]
}

variable "create_node_pool" {
  type = bool
  default = true
}

variable "custom_image_name" {
  default = "custom-jenkins"
}

variable "custom_image_tag" {
  default = "latest"
}

variable "jenkins_plugins" {
  type = list(string)
  default = [ "configuration-as-code", "kubernetes", "kubernetes-credentials-provider", "job-dsl", "github", "credentials", "workflow-multibranch", "workflow-aggregator", "pipeline-stage-view", "git", "oracle-cloud-infrastructure-devops", "bouncycastle-api", "ssh-credentials" ]
}

variable "ocir_compartment_id" {}
variable "auth_token" {
  sensitive = true
}
