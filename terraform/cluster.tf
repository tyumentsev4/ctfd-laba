data "selectel_mks_kube_versions_v1" "versions" {
  project_id = selectel_vpc_project_v2.project.id
  region     = var.selectel_pool
}

resource "selectel_mks_cluster_v1" "cluster_1" {
  name                              = "ctfd-k8s-cluster"
  project_id                        = selectel_vpc_project_v2.project.id
  region                            = var.selectel_pool
  kube_version                      = data.selectel_mks_kube_versions_v1.versions.default_version
  zonal                             = true
  enable_patch_version_auto_upgrade = false
  network_id                        = openstack_networking_network_v2.network_1.id
  subnet_id                         = openstack_networking_subnet_v2.subnet_1.id
  maintenance_window_start          = "00:00:00"
  oidc {
    enabled       = false
    issuer_url    = ""
    client_id     = ""
    provider_name = ""
  }
}

resource "selectel_mks_nodegroup_v1" "nodegroup_1" {
  cluster_id                   = selectel_mks_cluster_v1.cluster_1.id
  project_id                   = selectel_vpc_project_v2.project.id
  region                       = selectel_mks_cluster_v1.cluster_1.region
  install_nvidia_device_plugin = false
  preemptible                  = true
  availability_zone            = var.selectel_segment
  nodes_count                  = 1
  cpus                         = 8
  ram_mb                       = 16384
  volume_gb                    = 32
  volume_type                  = "fast.${var.selectel_segment}"
}

data "selectel_mks_kubeconfig_v1" "kubeconfig" {
  cluster_id = selectel_mks_cluster_v1.cluster_1.id
  project_id = selectel_mks_cluster_v1.cluster_1.project_id
  region     = selectel_mks_cluster_v1.cluster_1.region
}

output "kubeconfig" {
  value     = data.selectel_mks_kubeconfig_v1.kubeconfig.raw_config
  sensitive = true
}
