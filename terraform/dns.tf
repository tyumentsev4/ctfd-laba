resource "selectel_domains_zone_v2" "zone_1" {
  name       = "sel.dmdev.click."
  project_id = selectel_vpc_project_v2.project.id
}

resource "selectel_domains_rrset_v2" "grafana_domain_record" {
  zone_id    = selectel_domains_zone_v2.zone_1.id
  name       = "grafana.sel.dmdev.click."
  type       = "A"
  ttl        = 300
  project_id = selectel_vpc_project_v2.project.id
  records {
    content = openstack_networking_floatingip_v2.ingress_loadbalancer_ip.address
  }
}

resource "selectel_domains_rrset_v2" "ctfd_domain_record" {
  zone_id    = selectel_domains_zone_v2.zone_1.id
  name       = "ctfd.sel.dmdev.click."
  type       = "A"
  ttl        = 300
  project_id = selectel_vpc_project_v2.project.id
  records {
    content = openstack_networking_floatingip_v2.ingress_loadbalancer_ip.address
  }
}
