terraform {
  required_providers {
    selectel = {
      source  = "selectel/selectel"
      version = "6.4.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "2.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  required_version = ">= 1.6.3"

  backend "http" {
  }

}

provider "selectel" {
  domain_name = var.selectel_domain_name
  username    = var.selectel_username
  password    = var.selectel_password
  auth_region = var.selectel_pool
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3/"
}

provider "openstack" {
  auth_url    = "https://cloud.api.selcloud.ru/identity/v3"
  domain_name = var.selectel_domain_name
  tenant_id   = selectel_vpc_project_v2.project.id
  user_name   = selectel_iam_serviceuser_v1.serviceuser_1.name
  password    = selectel_iam_serviceuser_v1.serviceuser_1.password
  region      = var.selectel_pool
}
