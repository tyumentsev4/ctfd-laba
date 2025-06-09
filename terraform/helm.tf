provider "helm" {
  kubernetes {
    host                   = data.selectel_mks_kubeconfig_v1.kubeconfig.server
    client_certificate     = base64decode(data.selectel_mks_kubeconfig_v1.kubeconfig.client_cert)
    client_key             = base64decode(data.selectel_mks_kubeconfig_v1.kubeconfig.client_key)
    cluster_ca_certificate = base64decode(data.selectel_mks_kubeconfig_v1.kubeconfig.cluster_ca_cert)
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "ingrss-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  version          = "4.12.1"
  create_namespace = true
  atomic           = true
  set {
    name  = "controller.service.loadBalancerIP"
    value = openstack_networking_floatingip_v2.ingress_loadbalancer_ip.address
  }

  depends_on = [
    selectel_mks_cluster_v1.cluster_1,
    selectel_mks_nodegroup_v1.nodegroup_1,
    openstack_networking_floatingip_v2.ingress_loadbalancer_ip
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "v1.17.1"
  create_namespace = true
  atomic           = true
  set {
    name  = "crds.enabled"
    value = true
  }
  depends_on = [
    selectel_mks_cluster_v1.cluster_1,
    selectel_mks_nodegroup_v1.nodegroup_1,
    helm_release.nginx_ingress
  ]
}

resource "helm_release" "driver_nfs" {
  name             = "csi-driver-nfs"
  repository       = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  chart            = "csi-driver-nfs"
  namespace        = "driver-nfs"
  version          = "v4.10.0"
  create_namespace = true
  atomic           = true
  depends_on = [
    selectel_mks_cluster_v1.cluster_1,
    selectel_mks_nodegroup_v1.nodegroup_1
  ]
}

resource "helm_release" "prometheus_operator" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.id
  version    = "69.4.1"
  atomic     = true
  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_storage_class.nfs_storage_class,
    helm_release.cert_manager,
    helm_release.nginx_ingress
  ]
  values = [
    file("../values/selectel/kube-prometheus-stack.yaml")
  ]
  set_list {
    name  = "grafana.ingress.hosts"
    value = [trimsuffix(selectel_domains_rrset_v2.grafana_domain_record.name, ".")]
  }
  set_list {
    name  = "grafana.ingress.tls[0].hosts"
    value = [trimsuffix(selectel_domains_rrset_v2.grafana_domain_record.name, ".")]
  }
}

resource "helm_release" "mariadb_galera" {
  name       = "mariadb-galera"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "mariadb-galera"
  namespace  = kubernetes_namespace.ctfd.id
  version    = "14.1.4"
  atomic     = true
  depends_on = [
    helm_release.prometheus_operator,
    kubernetes_namespace.ctfd,
    kubernetes_secret.mariadb_galera,
    kubernetes_storage_class.nfs_storage_class,
  ]
  values = [
    file("../values/selectel/mariadb-galera.yaml")
  ]
}

resource "helm_release" "redis_cluster" {
  name       = "redis-cluster"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "redis-cluster"
  namespace  = kubernetes_namespace.ctfd.id
  version    = "11.4.3"
  atomic     = true
  depends_on = [
    helm_release.prometheus_operator,
    kubernetes_namespace.ctfd,
    kubernetes_secret.redis_cluster,
    kubernetes_storage_class.nfs_storage_class,
  ]
  values = [
    file("../values/selectel/redis-cluster.yaml")
  ]
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.logging.id
  version    = "6.27.0"
  atomic     = true
  depends_on = [
    helm_release.prometheus_operator,
    kubernetes_storage_class.nfs_storage_class,
  ]
  values = [
    file("../values/selectel/loki.yaml")
  ]
}

resource "helm_release" "vector" {
  name       = "vector"
  repository = "https://helm.vector.dev"
  chart      = "vector"
  namespace  = kubernetes_namespace.logging.id
  version    = "0.41.0"
  atomic     = true
  depends_on = [
    helm_release.loki,
    kubernetes_namespace.logging
  ]
  values = [
    file("../values/selectel/vector.yaml")
  ]
}

resource "helm_release" "ctfd" {
  name      = "ctfd"
  chart     = "../ctfd"
  namespace = kubernetes_namespace.ctfd.id
  version   = "1.0.0"
  values = [
    file("../values/selectel/ctfd.yaml")
  ]
  set {
    name  = "ingress.hosts[0].host"
    value = trimsuffix(selectel_domains_rrset_v2.ctfd_domain_record.name, ".")
  }
  set_list {
    name  = "ingress.tls[0].hosts"
    value = [trimsuffix(selectel_domains_rrset_v2.ctfd_domain_record.name, ".")]
  }
  depends_on = [
    helm_release.cert_manager,
    helm_release.driver_nfs,
    helm_release.mariadb_galera,
    helm_release.nginx_ingress,
    helm_release.redis_cluster,
    kubernetes_namespace.ctfd
  ]
}
