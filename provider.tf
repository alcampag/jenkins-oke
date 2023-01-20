terraform {
  required_version = "~> 1.1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.102.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

provider "oci" {
  region = var.region
}

provider "oci" {
  region = element([for reg in data.oci_identity_region_subscriptions.region_subscriptions_data.region_subscriptions : reg if reg.is_home_region ],0).region_name
  alias = "home"
}

provider "kubernetes" {
  host                   = local.kube_host
  cluster_ca_certificate = local.kube_cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", local.kube_cluster_id, "--region", var.region]
    command     = "oci"
  }
}
