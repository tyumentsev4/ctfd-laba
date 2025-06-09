provider "kubernetes" {
  host                   = data.selectel_mks_kubeconfig_v1.kubeconfig.server
  cluster_ca_certificate = base64decode(data.selectel_mks_kubeconfig_v1.kubeconfig.cluster_ca_cert)
  client_certificate     = base64decode(data.selectel_mks_kubeconfig_v1.kubeconfig.client_cert)
  client_key             = base64decode(data.selectel_mks_kubeconfig_v1.kubeconfig.client_key)
}

provider "kubectl" {
  host                   = data.selectel_mks_kubeconfig_v1.kubeconfig.server
  cluster_ca_certificate = base64decode(data.selectel_mks_kubeconfig_v1.kubeconfig.cluster_ca_cert)
  client_certificate = base64decode(data.selectel_mks_kubeconfig_v1.kubeconfig.client_cert)
  client_key = base64decode(data.selectel_mks_kubeconfig_v1.kubeconfig.client_key)
}

resource "kubernetes_namespace" "ctfd" {
  metadata {
    name = "ctfd"
    labels = {
      "prometheus" : "prometheus-operator"
    }
  }
  depends_on = [
    selectel_mks_nodegroup_v1.nodegroup_1,
    selectel_mks_cluster_v1.cluster_1
  ]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "prometheus" : "prometheus-operator"
    }
  }
  depends_on = [
    selectel_mks_nodegroup_v1.nodegroup_1,
    selectel_mks_cluster_v1.cluster_1
  ]

}

resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
    labels = {
      "prometheus" = "prometheus-operator"
    }
  }
  depends_on = [
    selectel_mks_nodegroup_v1.nodegroup_1,
    selectel_mks_cluster_v1.cluster_1
  ]

}

resource "kubernetes_secret" "mariadb_galera" {
  metadata {
    name      = "mariadb-galera-secret"
    namespace = kubernetes_namespace.ctfd.id
  }
  data = {
    "mariadb-root-password"               = var.mariadb_root_password
    "mariadb-galera-mariabackup-password" = var.mariadb_mariabackup_password
    "mariadb-password"                    = var.mariadb_password
  }
  depends_on = [
    selectel_mks_nodegroup_v1.nodegroup_1,
    selectel_mks_cluster_v1.cluster_1
  ]
}

resource "kubernetes_secret" "redis_cluster" {
  metadata {
    name      = "redis-cluster-secret"
    namespace = kubernetes_namespace.ctfd.id
  }
  data = {
    "redis-password" = var.redis_password
  }
  depends_on = [
    selectel_mks_nodegroup_v1.nodegroup_1,
    selectel_mks_cluster_v1.cluster_1
  ]

}

resource "kubernetes_storage_class" "nfs_storage_class" {
  metadata {
    name = "vm-nfs"

  }
  storage_provisioner = "nfs.csi.k8s.io"
  parameters = {
    "server" = openstack_networking_port_v2.port_1_nfs01.fixed_ip[0].ip_address
    "share"  = "/data/nfs"
  }
  depends_on = [
    null_resource.ansible_provision,
    helm_release.driver_nfs
  ]
}

resource "kubectl_manifest" "mariadb_dashboard" {
  yaml_body =   file("../manifests/selectel/mariadb-galera-dashboard.yaml")
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body =  file("../manifests/selectel/clusterIssuer.yaml")
  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "redis_dashboard" {
  yaml_body   = file("../manifests/selectel/redis-dashboard.yaml")
  depends_on = [kubernetes_namespace.monitoring]
}
