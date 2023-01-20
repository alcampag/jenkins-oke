variable "image" {
}

variable "tag" {
}

variable "registry_id" {
}

variable "registry_compartment_id" {
}

variable "registry_server" {
}

variable "registry_username" {
}

variable "registry_password" {
}

variable "registry_email" {
}

# JCaS parameters

variable "create_agent_namespace" {
    type = bool
}

variable "jenkins_service_name" {}

variable "jenkins_service_port" {
    type = number
}

variable "jenkins_controller_namespace" {}

variable "jenkins_admin_username" {}

variable "jenkins_admin_password" {
}

variable "agent_namespace" {
}

variable "max_concurrent_agents" {
    type = number
}